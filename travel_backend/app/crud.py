# app/crud.py
import asyncio
import asyncpg
import logging
import math
import json # <-- Make sure json is imported
import re # Import regex if needed for advanced text searching (like in get_best_places_for_user)
from typing import List, Dict, Optional, Tuple, Set # Added Set
from datetime import datetime # Import datetime
import aiohttp # <--- Import aiohttp
from app.image_fetcher import DEFAULT_IMAGE_PLACEHOLDER, fetch_and_cache_image_for_place # <--- Import the new 

# Import Models FIRST (Generally safe)
from app.config import settings
from app.models import (
    Landmark, NaturalWonder, PlaceBase, RestaurantFood, Place, RecommendedPlace,
    UserCreate, UserInDB # User models needed here
)
# Import Utilities (Generally safe)
from app.utils import calculate_distance_km, calculate_bounding_box

# DO NOT import anything from app.security at the top level here to avoid circular imports

logger = logging.getLogger(__name__)

# Mapping from category name to table and Pydantic model
CATEGORY_MAP = {
    "landmark": {"table": "landmarks", "model": Landmark},
    "natural_wonder": {"table": "natural_wonders", "model": NaturalWonder},
    "restaurant_food": {"table": "restaurants_food", "model": RestaurantFood},
}

# --- Helper Function to Safely Process Tags ---
def _prepare_tags_for_pydantic(record_dict: Dict) -> Optional[Dict]:
    """Checks and attempts to parse the 'tags' field, returning a dict or None."""
    tags_value = record_dict.get('tags')
    record_id = record_dict.get('id', 'N/A') # For logging
    if isinstance(tags_value, dict): return tags_value
    elif isinstance(tags_value, str):
        logger.warning(f"Record ID {record_id} has tags stored as string. Attempting parse.")
        try:
            parsed_tags = json.loads(tags_value)
            return parsed_tags if isinstance(parsed_tags, dict) else None
        except json.JSONDecodeError:
            logger.error(f"Failed to parse tags JSON string for ID {record_id}.")
            return None
    elif tags_value is None: return None
    else: logger.warning(f"Unexpected type for tags: {type(tags_value)} for ID {record_id}."); return None
    
# --- Helper to fetch total count ---
async def get_total_count(conn: asyncpg.Connection, base_query: str, params: list) -> int:
    """Fetches the total count for a given query. Accepts list params."""
    count_query = f"SELECT COUNT(*) FROM ({base_query}) AS subquery"
    try:
        count_result = await conn.fetchval(count_query, *params)
        return count_result if count_result is not None else 0
    except Exception as e:
        logger.error(f"Error fetching total count: {e}")
        return 0

# --- User CRUD Functions ---

async def get_user_by_email(conn: asyncpg.Connection, email: str) -> Optional[UserInDB]:
    """Fetches a user from the database by email."""
    # This function is imported by security.py
    query = "SELECT * FROM users WHERE email = $1"
    try:
        record = await conn.fetchrow(query, email)
        if record:
            # Convert record to dict before passing to Pydantic model
            return UserInDB(**dict(record))
        return None
    except Exception as e:
        logger.error(f"Error fetching user by email {email}: {e}")
        return None

async def create_user(conn: asyncpg.Connection, user: UserCreate) -> Optional[UserInDB]:
    """Creates a new user in the database."""
    # *** IMPORT get_password_hash LOCALLY inside the function ***
    from app.security import get_password_hash # Import locally to break cycle
    hashed_password = get_password_hash(user.password)
    query = """
        INSERT INTO users (email, hashed_password, full_name, is_active, is_superuser)
        VALUES ($1, $2, $3, TRUE, FALSE)
        RETURNING id, email, hashed_password, full_name, is_active, is_superuser, created_at;
    """
    try:
        full_name = getattr(user, 'full_name', None)
        record = await conn.fetchrow(query, user.email, hashed_password, full_name)
        if record:
             # Convert record to dict before passing to Pydantic model
            return UserInDB(**dict(record))
        return None
    except asyncpg.exceptions.UniqueViolationError:
        logger.warning(f"Attempted to register duplicate email: {user.email}")
        return None
    except Exception as e:
        logger.error(f"Error creating user {user.email}: {e}")
        return None

# --- Refresh Token CRUD Functions ---
# These don't import from security.py, so they are fine

async def create_refresh_token_db(conn: asyncpg.Connection, user_id: int, token: str, expires_at: datetime) -> bool:
    """Stores a refresh token in the database."""
    query = """
        INSERT INTO refresh_tokens (user_id, token, expires_at)
        VALUES ($1, $2, $3);
    """
    try:
        await conn.execute(query, user_id, token, expires_at)
        logger.info(f"Stored refresh token for user_id {user_id}")
        return True
    except asyncpg.exceptions.UniqueViolationError:
        logger.error(f"Attempted to insert duplicate refresh token for user {user_id}.")
        return False
    except Exception as e:
        logger.error(f"Error storing refresh token for user {user_id}: {e}")
        return False

async def get_refresh_token_db(conn: asyncpg.Connection, token: str) -> Optional[Dict]:
    """Retrieves a refresh token record from the database by the token string."""
    query = """
        SELECT id, user_id, token, expires_at, revoked_at
        FROM refresh_tokens
        WHERE token = $1;
    """
    try:
        record = await conn.fetchrow(query, token)
        return dict(record) if record else None
    except Exception as e:
        logger.error(f"Error fetching refresh token: {e}")
        return None

async def revoke_refresh_token_db(conn: asyncpg.Connection, token_id: int) -> bool:
    """Marks a refresh token as revoked by setting revoked_at."""
    query = """
        UPDATE refresh_tokens
        SET revoked_at = NOW()
        WHERE id = $1 AND revoked_at IS NULL;
    """
    try:
        result = await conn.execute(query, token_id)
        updated_count = int(result.split()[-1]) if result and result != "UPDATE 0" else 0
        if updated_count > 0:
            logger.info(f"Revoked refresh token with id {token_id}")
            return True
        else:
            logger.warning(f"Refresh token with id {token_id} not found or already revoked.")
            return False
    except Exception as e:
        logger.error(f"Error revoking refresh token id {token_id}: {e}")
        return False

async def delete_refresh_token_db(conn: asyncpg.Connection, token_id: int) -> bool:
    """Hard deletes a refresh token entry."""
    query = "DELETE FROM refresh_tokens WHERE id = $1;"
    try:
        await conn.execute(query, token_id)
        logger.info(f"Deleted refresh token with id {token_id}")
        return True
    except Exception as e:
        logger.error(f"Error deleting refresh token id {token_id}: {e}")
        return False

async def delete_expired_refresh_tokens_db(conn: asyncpg.Connection) -> int:
    """Deletes all expired or revoked refresh tokens."""
    query = "DELETE FROM refresh_tokens WHERE expires_at < NOW() OR revoked_at IS NOT NULL;"
    try:
        result = await conn.execute(query)
        deleted_count = int(result.split()[-1]) if result and result != "DELETE 0" else 0
        if deleted_count > 0:
            logger.info(f"Deleted {deleted_count} expired/revoked refresh tokens.")
        return deleted_count
    except Exception as e:
        logger.error(f"Error deleting expired refresh tokens: {e}")
        return 0


# --- Place CRUD Functions ---


async def get_places_near_location(
    conn: asyncpg.Connection, latitude: float, longitude: float, radius_km: float,
    page: int, size: int, category: Optional[str] = None
) -> Tuple[List[Place], int]:
    """
    Fetches places within a radius, including images and address.
    Uses bounding box + application-level distance filtering + concurrent image fetching.
    """
    size = max(1, min(settings.max_page_size, size))
    page = max(1, page)
    offset = (page - 1) * size

    bbox = calculate_bounding_box(latitude, longitude, radius_km * 1.1) # Bbox slightly larger
    if not bbox:
        logger.warning("Invalid coordinates or radius for bounding box.")
        return [], 0

    # Determine tables and models to query
    tables_to_query = []
    if category and category in CATEGORY_MAP:
        tables_to_query = [(category, CATEGORY_MAP[category])]
    elif category:
        logger.warning(f"Invalid category '{category}' specified, querying all.")
        tables_to_query = CATEGORY_MAP.items()
    else:
        tables_to_query = CATEGORY_MAP.items()

    candidate_records = [] # Store raw records matching bbox first
    all_params = [bbox["min_lat"], bbox["max_lat"], bbox["min_lon"], bbox["max_lon"]]

    # Fetch candidates from all relevant tables within bbox
    for cat_name, cat_info in tables_to_query:
        table_name = cat_info["table"]
        query = f""" SELECT *, '{cat_name}' as category FROM "{table_name}"
                    WHERE latitude BETWEEN $1 AND $2 AND longitude BETWEEN $3 AND $4 """
        try:
            logger.info(f"Querying {table_name} within bounding box for nearby...")
            records = await conn.fetch(query, *all_params)
            candidate_records.extend(records)
            logger.info(f"Fetched {len(records)} candidate records from {table_name}.")
        except Exception as e:
            logger.error(f"Error querying nearby candidates from {table_name}: {e}")

    # Filter candidates by actual distance and prepare for image fetch
    places_within_radius = []
    image_fetch_tasks = []
    records_for_image_fetch = [] # Keep track of records needing images

    logger.info(f"Filtering {len(candidate_records)} candidates by distance ({radius_km}km)...")
    for record in candidate_records:
        record_dict = dict(record)
        lat2, lon2 = record_dict.get('latitude'), record_dict.get('longitude')
        if lat2 is not None and lon2 is not None:
            dist_km = calculate_distance_km(latitude, longitude, lat2, lon2)
            if dist_km <= radius_km:
                record_dict['distance_km'] = round(dist_km, 2)
                record_dict['tags'] = _prepare_tags_for_pydantic(record_dict) # Prepare tags

                # Construct Address
                address_parts = []; tags = record_dict.get('tags') or {}
                if tags.get('addr:full'): address_parts.append(tags['addr:full'])
                else:
                    addr_keys = ['addr:housenumber', 'addr:street', 'addr:city', 'addr:postcode', 'addr:country']
                    for key in addr_keys:
                        if tags.get(key): address_parts.append(tags[key])
                record_dict['address'] = ", ".join(part for part in address_parts if part) or None

                places_within_radius.append(record_dict) # Add processed dict
                records_for_image_fetch.append(record_dict) # Add to list for image tasks
        else:
             logger.warning(f"Skipping record ID {record_dict.get('id')} due to missing coordinates.")


    # Fetch images concurrently if needed
    image_urls = []
    if records_for_image_fetch:
        async with aiohttp.ClientSession() as session:
            for record_dict in records_for_image_fetch:
                 # Create task for each place dict within radius
                 image_fetch_tasks.append(fetch_and_cache_image_for_place(session, conn, record_dict))

            if image_fetch_tasks:
                logger.info(f"Fetching/caching images for {len(image_fetch_tasks)} nearby places...")
                try:
                    image_urls = await asyncio.gather(*image_fetch_tasks)
                except Exception as gather_error:
                     logger.error(f"Error during asyncio.gather for image fetching: {gather_error}")
                     # Handle error: maybe fill with defaults?
                     image_urls = [DEFAULT_IMAGE_PLACEHOLDER] * len(image_fetch_tasks)
                logger.info("Finished image fetching/caching.")

    # Combine places with fetched images
    final_processed_places = []
    if len(places_within_radius) == len(image_urls): # Ensure lists match
        for i, place_dict in enumerate(places_within_radius):
            place_dict['image_url'] = image_urls[i]
            final_processed_places.append(place_dict)
    else: # Fallback if lengths mismatch (shouldn't happen ideally)
         logger.error("Mismatch between places within radius and fetched image URLs count.")
         for place_dict in places_within_radius:
             place_dict['image_url'] = DEFAULT_IMAGE_PLACEHOLDER # Assign default
             final_processed_places.append(place_dict)


    # Sort final list by distance
    final_processed_places.sort(key=lambda p: p.get('distance_km', float('inf')))
    total_count_within_radius = len(final_processed_places)

    # Apply pagination to the final sorted list
    start_index = offset
    end_index = offset + size
    paginated_items_dicts = final_processed_places[start_index:end_index]

    # Convert final paginated dicts to Pydantic models
    paginated_items_models = []
    for item_dict in paginated_items_dicts:
        cat_name = item_dict.get('category', 'unknown')
        model_class = CATEGORY_MAP.get(cat_name, {}).get('model', PlaceBase) # Fallback to PlaceBase
        try:
            paginated_items_models.append(model_class(**item_dict))
        except Exception as e:
            logger.warning(f"Pydantic parse failed for nearby place ID {item_dict.get('id')}: {e}")
            logger.debug(f"Dict causing failure for nearby: {item_dict}")

    logger.info(f"Returning {len(paginated_items_models)} places within {radius_km}km radius (page {page}, size {size}). Total matching radius: {total_count_within_radius}")
    # Return list of Place union models and the total count found *within the radius*
    return paginated_items_models, total_count_within_radius

async def get_places_by_type(
    conn: asyncpg.Connection, place_type_key: str, place_type_value: str,
    city_id: Optional[int] = None, page: int = 1, size: int = 20
) -> Tuple[List[Place], int]:
    """
    Fetches places based on a specific OSM tag, including images and address.
    """
    size = max(1, min(settings.max_page_size, size))
    page = max(1, page)
    offset = (page - 1) * size

    # Determine target table based on key (simplified heuristic)
    possible_tables = []
    if place_type_key in ['natural', 'leisure']: possible_tables.append(CATEGORY_MAP['natural_wonder'])
    if place_type_key in ['historic', 'man_made', 'tourism']: possible_tables.append(CATEGORY_MAP['landmark'])
    if place_type_key in ['amenity', 'shop']:
        possible_tables.append(CATEGORY_MAP['restaurant_food'])
        possible_tables.append(CATEGORY_MAP['landmark']) # Include landmarks for amenity=place_of_worship etc.

    if not possible_tables:
         logger.warning(f"No table identified for tag key '{place_type_key}'.")
         return [], 0

    results_models = []
    total_count = 0
    # For simplicity, query only the first matched table. A robust solution might UNION results.
    primary_cat_info = possible_tables[0]
    table = primary_cat_info['table']
    model = primary_cat_info['model']
    # Find category name corresponding to the table being queried
    category_name = next((k for k, v in CATEGORY_MAP.items() if v['table'] == table), "unknown")

    param_list = [place_type_key, place_type_value]
    param_idx = 3 # Start next param index at 3
    city_filter_sql = ""
    if city_id is not None:
        city_filter_sql = f"AND city_id = ${param_idx}"
        param_list.append(city_id)
        param_idx += 1

    # Construct queries
    base_query = f""" SELECT *, '{category_name}' as category FROM "{table}"
                      WHERE tags ->> $1 = $2 {city_filter_sql} """
    paginated_query = base_query + f" ORDER BY id LIMIT ${param_idx} OFFSET ${param_idx + 1}"
    param_list_paginated = param_list + [size, offset]

    try:
        logger.info(f"Querying {table} for '{place_type_key}'='{place_type_value}'...")
        # Get total count first using original filters
        total_count = await get_total_count(conn, base_query, param_list)
        logger.info(f"Total matching '{place_type_key}'='{place_type_value}': {total_count}")

        records = []
        if total_count > 0 and offset < total_count:
            records = await conn.fetch(paginated_query, *param_list_paginated)
            logger.info(f"Fetched {len(records)} records for page {page}, size {size}.")
        else:
             logger.info("Offset exceeds total count or no items found, skipping data fetch.")


        # Fetch images and process results if records exist
        if records:
            processed_records = [] # Store dicts after initial processing
            image_fetch_tasks = []
            async with aiohttp.ClientSession() as session:
                for r in records:
                    record_dict = dict(r)
                    record_dict['tags'] = _prepare_tags_for_pydantic(record_dict)
                    record_dict['category'] = category_name # Assign category

                    # Construct Address
                    address_parts = []; tags = record_dict.get('tags') or {}
                    if tags.get('addr:full'): address_parts.append(tags['addr:full'])
                    else:
                        addr_keys = ['addr:housenumber', 'addr:street', 'addr:city', 'addr:postcode', 'addr:country']
                        for key in addr_keys:
                             if tags.get(key): address_parts.append(tags[key])
                    record_dict['address'] = ", ".join(part for part in address_parts if part) or None

                    processed_records.append(record_dict) # Store processed dict
                    # Create image fetch task
                    image_fetch_tasks.append(fetch_and_cache_image_for_place(session, conn, record_dict))

                # Fetch images concurrently
                logger.info(f"Fetching/caching images for {len(image_fetch_tasks)} places by type...")
                image_urls = await asyncio.gather(*image_fetch_tasks)
                logger.info("Finished image fetching/caching.")

                # Combine images and convert to Pydantic models
                if len(processed_records) == len(image_urls):
                    for i, item_dict in enumerate(processed_records):
                        item_dict['image_url'] = image_urls[i]
                        try:
                            # Use the model determined earlier for this table
                            results_models.append(model(**item_dict))
                        except Exception as e:
                            logger.warning(f"Pydantic parse failed for place by type ID {item_dict.get('id')} AFTER image fetch: {e}")
                else:
                     logger.error("Mismatch between processed records and image URLs count.")
                     # Fallback: Convert without images if mismatch
                     for item_dict in processed_records:
                         item_dict['image_url'] = DEFAULT_IMAGE_PLACEHOLDER
                         try: results_models.append(model(**item_dict))
                         except Exception as e: logger.warning(...)


    except asyncpg.PostgresError as db_error:
        logger.error(f"Database error fetching places by type: {db_error}")
    except Exception as e:
        logger.exception(f"Unexpected error fetching places by type: {e}")

    return results_models, total_count

async def get_top_places(
    conn: asyncpg.Connection, criteria: str, time_window: str, limit: int,
    latitude: Optional[float] = None, longitude: Optional[float] = None, radius_km: Optional[float] = None
) -> List[RecommendedPlace]:
    """
    Fetches 'top' places based on criteria, optionally filtered by location.
    Includes images and address. Returns RecommendedPlace models.
    """
    if not isinstance(conn, asyncpg.Connection):
         logger.error(f"Invalid connection object passed to get_top_places: {type(conn)}")
         raise TypeError("Invalid database connection object.")

    items_models = [] # Will hold final RecommendedPlace models
    params = []
    param_idx = 1
    location_filter_sql = ""

    # --- Location Filtering (if provided) ---
    # ... (Keep bbox calculation and location_filter_sql construction) ...
    if latitude is not None and longitude is not None and radius_km is not None:
        bbox = calculate_bounding_box(latitude, longitude, radius_km)
        if bbox:
            location_filter_sql = f"WHERE latitude BETWEEN ${param_idx} AND ${param_idx+1} AND longitude BETWEEN ${param_idx+2} AND ${param_idx+3}"
            params.extend([bbox["min_lat"], bbox["max_lat"], bbox["min_lon"], bbox["max_lon"]])
            param_idx += 4
        else: latitude = longitude = radius_km = None # Disable distance calc later

    # --- Criteria Implementation ---
    if criteria == "recent":
        logger.info("get_top_places: Fetching recent landmarks.")
        table = "landmarks"
        category_name = "landmark"
        reason_text = ["Recently added landmark"]
        limit_param_idx = param_idx
        params.append(limit)
        query = f""" SELECT *, '{category_name}' as category FROM "{table}" {location_filter_sql}
                    ORDER BY created_at DESC NULLS LAST LIMIT ${limit_param_idx}; """
    # --- Add other criteria (popular, rated) here with their specific queries ---
    # elif criteria == "popular": ...
    else:
        logger.warning(f"Criteria '{criteria}' not implemented in get_top_places.")
        return []

    # --- Execute Query ---
    records = []
    if query:
        try:
            records = await conn.fetch(query, *params)
            logger.info(f"Fetched {len(records)} records for criteria '{criteria}' (limit {limit}).")
        except asyncpg.PostgresError as db_error:
             logger.error(f"Database error fetching top places for criteria '{criteria}': {db_error}")
             return [] # Return empty on DB error
        except Exception as e:
             logger.error(f"Unexpected error fetching top places for criteria '{criteria}': {e}")
             return []

    # --- Process Records: Image Fetch, Address, Distance, Model Conversion ---
    if records:
        processed_records = [] # Store dicts before image fetch
        image_fetch_tasks = []
        async with aiohttp.ClientSession() as session:
            for r in records:
                record_dict = dict(r)
                record_dict['tags'] = _prepare_tags_for_pydantic(record_dict)
                record_dict['category'] = category_name # Assign category determined by criteria logic

                # Construct Address
                address_parts = []; tags = record_dict.get('tags') or {}
                if tags.get('addr:full'): address_parts.append(tags['addr:full'])
                else:
                    addr_keys = ['addr:housenumber', 'addr:street', 'addr:city', 'addr:postcode', 'addr:country']
                    for key in addr_keys:
                         if tags.get(key): address_parts.append(tags[key])
                record_dict['address'] = ", ".join(part for part in address_parts if part) or None

                # Calculate Distance if location provided
                distance = None
                if latitude is not None and longitude is not None:
                     lat2, lon2 = record_dict.get('latitude'), record_dict.get('longitude')
                     if lat2 is not None and lon2 is not None: distance = calculate_distance_km(latitude, longitude, lat2, lon2)
                record_dict['distance_km'] = round(distance, 1) if distance is not None else None

                # Add Reason and Score
                record_dict['reason'] = reason_text # Based on criteria
                record_dict['relevance_score'] = None # Not applicable for simple 'top' lists

                processed_records.append(record_dict)
                # Add task to fetch image using the processed dict
                image_fetch_tasks.append(fetch_and_cache_image_for_place(session, conn, record_dict))

            # Fetch images concurrently
            logger.info(f"Fetching/caching images for {len(image_fetch_tasks)} top places...")
            image_urls = await asyncio.gather(*image_fetch_tasks)
            logger.info("Finished image fetching/caching.")

            # Combine images and convert to final Pydantic models
            if len(processed_records) == len(image_urls):
                for i, item_dict in enumerate(processed_records):
                    item_dict['image_url'] = image_urls[i]
                    try:
                        items_models.append(RecommendedPlace(**item_dict))
                    except Exception as e:
                        logger.warning(f"Pydantic parse failed for top place ID {item_dict.get('id')}: {e}")
                        logger.debug(f"Dict causing failure for top place: {item_dict}")
            else:
                 logger.error("Mismatch between processed records and image URLs count for top places.")
                 # Fallback? Or just return the models without images?

    return items_models

async def get_best_places_for_user(
    conn: asyncpg.Connection,
    user_id: int,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    radius_km: Optional[float] = 10.0,
    category: Optional[str] = None,
    interests: Optional[List[str]] = None,
    page: int = 1,
    size: int = 20
) -> Tuple[List[RecommendedPlace], int]:
    """
    Fetches personalized recommendations, filtering heavily in the database.
    Includes concurrent image fetching/caching and address construction.
    """
    size = max(1, min(settings.max_page_size, size))
    page = max(1, page)
    offset = (page - 1) * size

    # --- 1. Load User Preferences & Prepare Base Filters ---
    user_interests_set: Set[str] = set()
    # ... (Keep preference loading logic - replace dummy later) ...
    params = []
    param_idx = 1
    where_clauses = []
    # ... (Keep location bbox filter logic) ...
    # ... (Keep interest filter logic - ensure JSONB @> fix is applied) ...
    where_sql = ""
    if where_clauses: where_sql = "WHERE " + " AND ".join(where_clauses)

    # --- 2. Determine Target Tables and Specific Category Filter ---
    query_parts = []
    count_query_parts = []
    specific_tag_filter = ""
    tables_to_target = []
    # ... (Keep logic to determine tables_to_target and specific_tag_filter based on category) ...
    if category:
        category_lower = category.lower()
        if category_lower in CATEGORY_MAP:
            cat_info = CATEGORY_MAP[category_lower]
            table = cat_info["table"]
            output_category = category_lower
            specific_filter_tuple = cat_info.get("tags_filter")
            specific_where = "" ; specific_params_part = []
            if specific_filter_tuple:
                 tag_key, tag_value = specific_filter_tuple
                 # Use param_idx for unique placeholders across all parts
                 specific_where = f"tags ->> ${param_idx} = ${param_idx+1}"
                 specific_params_part.extend([tag_key, tag_value])
                 param_idx += 2
            tables_to_target.append((table, output_category, specific_where, specific_params_part))
        else:
             logger.warning(f"Category '{category}' not mapped, querying all base tables.")
             for cat_name, cat_info in CATEGORY_MAP.items():
                  if cat_info.get("tags_filter") is None: tables_to_target.append((cat_info["table"], cat_name, "", []))
    else:
        logger.info("No category filter, querying all base tables.")
        for cat_name, cat_info in CATEGORY_MAP.items():
             if cat_info.get("tags_filter") is None: tables_to_target.append((cat_info["table"], cat_name, "", []))


    # --- 3. Construct UNION ALL Query Parts ---
    all_specific_params = [] # Store specific params for all parts
    current_specific_param_offset = len(params) # Where specific params start

    for table_name, output_category, specific_where, specific_params_part in tables_to_target:
        select_list = f"id, name, latitude, longitude, website, description, opening_hours, osm_type, osm_id, tags, '{output_category}' as category"
        if table_name == 'landmarks': select_list += ", entry_fee, NULL as cuisine"
        elif table_name == 'natural_wonders': select_list += ", entry_fee, NULL as cuisine"
        elif table_name == 'restaurants_food': select_list += ", NULL as entry_fee, cuisine"
        else: continue

        # Combine base WHERE with adjusted specific WHERE for this table part
        combined_where_clauses_part = list(where_clauses) # Start with base clauses
        if specific_where:
             adjusted_specific_where = specific_where
             # Adjust $N placeholders based on current total parameter count
             for i in range(len(specific_params_part)):
                 placeholder_old = f"${i+1}" # Placeholder in original specific_where string
                 placeholder_new = f"${current_specific_param_offset + i + 1}" # New placeholder index
                 adjusted_specific_where = adjusted_specific_where.replace(placeholder_old, placeholder_new, 1)
             combined_where_clauses_part.append(adjusted_specific_where)

        combined_where_sql_part = ""
        if combined_where_clauses_part:
            combined_where_sql_part = "WHERE " + " AND ".join(combined_where_clauses_part)

        query_parts.append(f'(SELECT {select_list} FROM "{table_name}" {combined_where_sql_part})')
        count_query_parts.append(f'(SELECT 1 FROM "{table_name}" {combined_where_sql_part})')
        # Add this part's specific params to the overall list
        all_specific_params.extend(specific_params_part)
        current_specific_param_offset += len(specific_params_part) # Update offset for next part

    if not query_parts:
        logger.warning("No valid query parts generated.")
        return [], 0

    # Combine all parameters: base + all specific ones
    all_params = params + all_specific_params

    # --- 4. Build Final Count & Data Queries ---
    full_count_query = "SELECT COUNT(*) FROM (" + " UNION ALL ".join(count_query_parts) + ") AS count_union"
    order_by_sql = "ORDER BY name NULLS LAST, id"
    limit_param_idx = len(all_params) + 1
    offset_param_idx = len(all_params) + 2
    limit_offset_sql = f"LIMIT ${limit_param_idx} OFFSET ${offset_param_idx}"
    params_paginated = all_params + [size, offset]

    full_data_query = " UNION ALL ".join(query_parts)
    paginated_data_query = f"({full_data_query}) {order_by_sql} {limit_offset_sql}"

    logger.debug(f"Final COUNT Query: {full_count_query}")
    logger.debug(f"Final COUNT Params: {all_params}")
    logger.debug(f"Final DATA Query: {paginated_data_query}")
    logger.debug(f"Final DATA Params: {params_paginated}")

    # --- 5. Execute Queries ---
    final_items_models = []
    total_relevant_items = 0
    records = [] # Initialize records

    try:
        # Execute count query first
        total_relevant_items = await conn.fetchval(full_count_query, *all_params)
        total_relevant_items = total_relevant_items or 0
        logger.info(f"Total relevant items found matching filters: {total_relevant_items}")

        if total_relevant_items == 0 or offset >= total_relevant_items:
             logger.info("Offset exceeds total items or no items found, skipping data fetch.")
             return [], total_relevant_items

        # Execute data query
        records = await conn.fetch(paginated_data_query, *params_paginated)
        logger.info(f"Fetched {len(records)} records for page {page}, size {size}.")

    except asyncpg.PostgresError as db_error:
        logger.error(f"Database error fetching recommendations for user {user_id}: {db_error}")
        return [], total_relevant_items # Return 0 models, but potentially the count if fetched
    except Exception as e:
        logger.exception(f"Unexpected error during query execution for user {user_id}: {e}")
        return [], total_relevant_items

    # --- 6. Post-Process Results (Scoring, Distance, Image Fetch, Address, Model Conversion) ---
    if records:
        processed_records_with_score = [] # Store dicts after scoring/processing
        image_fetch_tasks = []
        async with aiohttp.ClientSession() as session: # Create session for image fetching
            # --- PART 1: Scoring, Distance, Address, Prepare for Image Fetch ---
            max_score = 10.0
            for r in records:
                place = dict(r)
                score = 0.0; reasons = []; distance = None
                place['tags'] = _prepare_tags_for_pydantic(place) # Prepare tags

                # a) Proximity / Distance
                if latitude is not None and longitude is not None:
                    lat2, lon2 = place.get('latitude'), place.get('longitude')
                    if lat2 is not None and lon2 is not None:
                        distance = calculate_distance_km(latitude, longitude, lat2, lon2)
                        if radius_km and radius_km > 0: # Precise filter (optional)
                           if distance > radius_km: continue # Skip if outside precise radius
                           proximity_bonus = max(0, (1 - (distance / radius_km))) * (max_score / 2)
                           score += proximity_bonus; reasons.append(f"Nearby ({distance:.1f}km)")
                    place['distance_km'] = round(distance, 1) if distance is not None else None
                else: place['distance_km'] = None

                # b) Interest Matching Score
                if user_interests_set:
                    # ... (Keep interest matching logic, update 'score' and 'reasons') ...
                    pass # Your existing logic here
                place['relevance_score'] = round(score, 2)
                place['reason'] = reasons if reasons else None

                # c) Construct Address String
                address_parts = []; tags = place.get('tags') or {}
                if tags.get('addr:full'): address_parts.append(tags['addr:full'])
                else:
                    addr_keys = ['addr:housenumber', 'addr:street', 'addr:city', 'addr:postcode', 'addr:country']
                    for key in addr_keys:
                         if tags.get(key): address_parts.append(tags[key])
                place['address'] = ", ".join(part for part in address_parts if part) or None

                processed_records_with_score.append(place) # Add the processed dict
                # Create image fetch task using the processed dict
                image_fetch_tasks.append(fetch_and_cache_image_for_place(session, conn, place))


            # --- PART 2: Fetch Images Concurrently ---
            image_urls = []
            if image_fetch_tasks:
                logger.info(f"Fetching/caching images for {len(image_fetch_tasks)} best-for-you results...")
                try:
                    image_urls = await asyncio.gather(*image_fetch_tasks)
                except Exception as gather_error:
                     logger.error(f"Error during asyncio.gather for image fetching: {gather_error}")
                     image_urls = [DEFAULT_IMAGE_PLACEHOLDER] * len(image_fetch_tasks) # Fallback
                logger.info("Finished image fetching/caching.")

            # --- PART 3: Combine with Images and Convert to Pydantic Models ---
            if len(processed_records_with_score) == len(image_urls):
                for i, item_dict in enumerate(processed_records_with_score):
                    item_dict['image_url'] = image_urls[i] # Assign fetched/cached URL
                    try:
                        # Convert final dict (with score, reason, distance, address, image_url) to model
                        final_items_models.append(RecommendedPlace(**item_dict))
                    except Exception as e:
                         logger.warning(f"Pydantic parse failed for recommended place ID {item_dict.get('id')}: {e}")
                         logger.debug(f"Dict causing failure: {item_dict}")
            else:
                 logger.error("Mismatch between processed records and image URLs count. Adding default images.")
                 for item_dict in processed_records_with_score: # Fallback
                     item_dict['image_url'] = DEFAULT_IMAGE_PLACEHOLDER
                     try: final_items_models.append(RecommendedPlace(**item_dict))
                     except Exception as e: logger.warning(f"Pydantic parse failed (fallback) ID {item_dict.get('id')}: {e}")


    logger.info(f"Returning {len(final_items_models)} recommended places for user {user_id}. Total relevant: {total_relevant_items}")
    return final_items_models, total_relevant_items

async def authenticate_user(conn: asyncpg.Connection, email: str, password: str) -> Optional[UserInDB]:
    """Authenticates a user by email and password."""
    from app.security import verify_password # Avoid circular import at module level
    user = await get_user_by_email(conn, email)
    if not user:
        logger.debug(f"Authentication failed: User '{email}' not found.")
        return None
    if not user.is_active:
         logger.debug(f"Authentication failed: User '{email}' is inactive.")
         return None
    if not verify_password(password, user.hashed_password):
        logger.debug(f"Authentication failed: Incorrect password for user '{email}'.")
        return None
    return user

async def update_user_preferences_db(conn: asyncpg.Connection, user_id: int, preferences: Dict) -> bool:
    """
    Updates the preferences JSONB column for a specific user.
    Expects `preferences` to be a dictionary (e.g., {"interests": ["hiking", ...]}).
    """
    # You might want more validation or specific structure within the JSONB
    query = """
        UPDATE users
        SET preferences = $1::jsonb -- Cast the parameter to jsonb
        WHERE id = $2;
    """
    try:
        # Convert preferences dict to JSON string for the query parameter
        preferences_json = json.dumps(preferences)
        result = await conn.execute(query, preferences_json, user_id)
        # Check if a row was actually updated
        updated_count = int(result.split()[-1]) if result and result != "UPDATE 0" else 0
        if updated_count > 0:
            logger.info(f"Successfully updated preferences for user_id {user_id}")
            return True
        else:
            logger.warning(f"User with id {user_id} not found during preference update.")
            return False # User not found
    except Exception as e:
        logger.error(f"Error updating preferences for user_id {user_id}: {e}")
        return False
    