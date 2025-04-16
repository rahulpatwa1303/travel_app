def _prepare_tags_for_pydantic(record_dict: Dict) -> Optional[Dict]:
    """Checks and attempts to parse the 'tags' field, returning a dict or None."""
    tags_value = record_dict.get('tags')
    record_id = record_dict.get('id', 'N/A') # For logging

    if isinstance(tags_value, dict):
        return tags_value # Already a dictionary, return as is
    elif isinstance(tags_value, str):
        # If it's a string, try to parse it as JSON
        logger.warning(f"Record ID {record_id} has tags stored as string. Attempting parse.")
        try:
            parsed_tags = json.loads(tags_value)
            # Ensure the parsed result is actually a dictionary
            if isinstance(parsed_tags, dict):
                return parsed_tags
            else:
                logger.error(f"Parsed tags string for record ID {record_id} did not result in a dict. Type: {type(parsed_tags)}. Setting tags to None.")
                return None
        except json.JSONDecodeError:
            logger.error(f"Failed to parse tags JSON string for record ID {record_id}. String content: {tags_value[:100]}... Setting tags to None.")
            return None # Set to None if JSON parsing fails
    elif tags_value is None:
        return None # None is acceptable
    else:
         # If it's not a string, not a dict, and not None, log warning and force to None
         logger.warning(f"Unexpected type for tags: {type(tags_value)} for record ID {record_id}. Setting tags to None.")
         return None



async def get_best_places_for_user(
    conn: asyncpg.Connection, user_id: int, latitude: Optional[float] = None, longitude: Optional[float] = None,
    radius_km: Optional[float] = 10.0, category: Optional[str] = None, interests: Optional[List[str]] = None,
    page: int = 1, size: int = 20
) -> Tuple[List[RecommendedPlace], int]:
    """ Fetches personalized recommendations for a user. """
    from app.config import settings

    size = max(1, min(settings.max_page_size, size))
    page = max(1, page)
    offset = (page - 1) * size

    # --- 1. Load User Preferences (Dummy Implementation) ---
    user_interests: Set[str] = set()
    # ... (Keep dummy profile logic as before) ...
    if interests: user_interests.update(i.lower().strip() for i in interests if i)
    else:
        if user_id == 1: user_interests = {"hiking", "nature", "park", "mountain", "peak", "waterfall", "viewpoint"}
        elif user_id == 2: user_interests = {"history", "museum", "castle", "art", "gallery", "restaurant", "architecture"}
        elif user_id == 3: user_interests = {"beach", "bar", "pub", "food", "nightlife", "cafe"}
        else: user_interests = {"park", "cafe", "restaurant", "shop"}
    logger.info(f"User {user_id} Interests: {user_interests}")


    # --- 2. Build Base Query using UNION ALL ---
    query_parts = []
    params = []
    param_idx = 1

    location_filter_sql = ""
    bbox = None
    # ... (Keep location filter logic as before) ...
    if latitude is not None and longitude is not None and radius_km is not None:
        bbox = calculate_bounding_box(latitude, longitude, radius_km * 1.1)
        if bbox:
            location_filter_sql = f"WHERE latitude BETWEEN ${param_idx} AND ${param_idx+1} AND longitude BETWEEN ${param_idx+2} AND ${param_idx+3}"
            params.extend([bbox["min_lat"], bbox["max_lat"], bbox["min_lon"], bbox["max_lon"]])
            param_idx += 4
        else: latitude = longitude = radius_km = None

    tables_to_query = CATEGORY_MAP.items()
    if category and category in CATEGORY_MAP: tables_to_query = [(category, CATEGORY_MAP[category])]
    elif category: logger.warning(f"Invalid category '{category}' specified, querying all.")

    # ... (Keep UNION ALL query construction logic as before) ...
    for cat_name, cat_info in tables_to_query:
        # ... (construct select_list and append to query_parts) ...
        table_name = cat_info["table"]
        select_list = "id, name, latitude, longitude, website, description, opening_hours, osm_type, osm_id, tags"
        if table_name == 'landmarks': select_list += f", entry_fee, '{cat_name}' as category, NULL as cuisine"
        elif table_name == 'natural_wonders': select_list += f", entry_fee, '{cat_name}' as category, NULL as cuisine"
        elif table_name == 'restaurants_food': select_list += f", NULL as entry_fee, '{cat_name}' as category, cuisine"
        else: continue
        query_parts.append(f'(SELECT {select_list} FROM "{table_name}" {location_filter_sql})')


    if not query_parts: return [], 0
    full_base_query = " UNION ALL ".join(query_parts)

    candidate_places = []
    try:
        logger.info(f"Fetching candidate places for user {user_id}...")
        # Fetch ALL candidates first (inefficient but simple for now)
        records = await conn.fetch(full_base_query, *params)
        logger.info(f"Fetched {len(records)} candidate records.")
        for r in records:
            record_dict = dict(r)
            record_dict['tags'] = _prepare_tags_for_pydantic(record_dict)
            candidate_places.append(record_dict)
    except Exception as e:
        logger.error(f"Error fetching candidate places for recommendations: {e}")
        return [], 0

    # --- 3. Calculate Relevance Score and Filter by Distance ---
    scored_places = []
    max_score = 10.0
    # ... (Keep scoring logic as before: proximity, interest matching) ...
    for place in candidate_places:
        score = 0.0; reasons = []; distance = None
        # Proximity
        if latitude is not None and longitude is not None and radius_km is not None and radius_km > 0:
            lat2, lon2 = place.get('latitude'), place.get('longitude')
            if lat2 is not None and lon2 is not None:
                distance = calculate_distance_km(latitude, longitude, lat2, lon2)
                if distance > radius_km: continue
                proximity_bonus = max(0, (1 - (distance / radius_km))) * (max_score / 2)
                score += proximity_bonus; reasons.append(f"Nearby ({distance:.1f}km)")
            else: distance = None
        else: distance = None
        # Interest Matching
        matched_interests = set(); place_name_lower = str(place.get('name','')).lower(); place_tags = place.get('tags') or {}
        for interest in user_interests:
            if interest in place_name_lower: matched_interests.add(interest); continue
            if interest == 'beach' and place_tags.get('natural') == 'beach': matched_interests.add(interest)
            elif interest in ['mountain', 'peak', 'hiking'] and place_tags.get('natural') == 'peak': matched_interests.add(interest)
            elif interest == 'museum' and place_tags.get('tourism') == 'museum': matched_interests.add(interest)
            elif interest == 'castle' and place_tags.get('historic') == 'castle': matched_interests.add(interest)
            # Add more checks...
        if matched_interests:
            interest_bonus_per_match = (max_score / 2) / max(1, len(user_interests))
            score += len(matched_interests) * interest_bonus_per_match
            reasons.append(f"Matches interests: {', '.join(sorted(list(matched_interests)))}")
        # Assign score, reason, distance
        place['relevance_score'] = round(score, 2)
        place['reason'] = reasons if reasons else None
        place['distance_km'] = round(distance, 1) if distance is not None else None
        scored_places.append(place)


    # --- 4. Rank and Paginate ---
    scored_places.sort(key=lambda p: p['relevance_score'], reverse=True)
    total_relevant_items = len(scored_places)
    start_index = offset
    end_index = offset + size
    paginated_items_dicts = scored_places[start_index:end_index]

    # --- 5. Convert to Pydantic Models ---
    final_items = []
    for item_dict in paginated_items_dicts:
        try:
            final_items.append(RecommendedPlace(**item_dict))
        except Exception as e:
             logger.warning(f"Failed to parse final dict into RecommendedPlace model for ID {item_dict.get('id')}: {e}")
             logger.debug(f"Dict causing failure: {item_dict}")

    logger.info(f"Returning {len(final_items)} recommended places for user {user_id} (page {page}, size {size}). Total relevant: {total_relevant_items}")
    return final_items, total_relevant_items


async def get_best_places_for_user(
    conn: asyncpg.Connection,
    user_id: int,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    radius_km: Optional[float] = 10.0,
    category: Optional[str] = None, # User-provided category like 'park' or 'landmark'
    interests: Optional[List[str]] = None,
    page: int = 1,
    size: int = 20
) -> Tuple[List[RecommendedPlace], int]:
    """
    Fetches personalized recommendations, filtering heavily in the database.
    Includes address construction from tags.
    """
    from app.config import settings # Local import okay

    size = max(1, min(settings.max_page_size, size))
    page = max(1, page)
    offset = (page - 1) * size

    # --- 1. Load User Preferences & Prepare Filters ---
    user_interests_set: Set[str] = set()
    # TODO: Replace dummy logic with actual DB lookup for user preferences based on user_id
    temp_interests = interests or []
    if not temp_interests: # Fallback to dummy profile if no interests provided
        if user_id == 1: user_interests_set = {"hiking", "nature", "park", "mountain", "peak", "waterfall", "viewpoint"}
        elif user_id == 2: user_interests_set = {"history", "museum", "castle", "art", "gallery", "restaurant", "architecture"}
        elif user_id == 3: user_interests_set = {"beach", "bar", "pub", "food", "nightlife", "cafe"}
        else: user_interests_set = {"park", "cafe", "restaurant", "shop"} # Generic fallback
    else:
         user_interests_set.update(i.lower().strip() for i in temp_interests if i)
    logger.info(f"User {user_id} Effective Interests for Query: {user_interests_set}")

    params = []
    param_idx = 1
    where_clauses = []

    # a) Location Filter (Bounding Box)
    bbox = None
    if latitude is not None and longitude is not None and radius_km is not None:
        bbox = calculate_bounding_box(latitude, longitude, radius_km * 1.1) # Bbox slightly larger OK
        if bbox:
            where_clauses.append(f"latitude BETWEEN ${param_idx} AND ${param_idx+1}")
            params.extend([bbox["min_lat"], bbox["max_lat"]])
            param_idx += 2
            where_clauses.append(f"longitude BETWEEN ${param_idx} AND ${param_idx+1}")
            params.extend([bbox["min_lon"], bbox["max_lon"]])
            param_idx += 2
        else:
            logger.warning("Invalid location/radius provided for bbox.")
            latitude = longitude = radius_km = None # Disable distance calculations later

    # b) Interest Filter (using JSONB operators)
    interest_filters_sql = []
    if user_interests_set:
        # Simple examples - expand this mapping based on your data/interests
        if 'hiking' in user_interests_set or 'mountain' in user_interests_set or 'peak' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'natural' = 'peak'")
             interest_filters_sql.append(f"tags ->> 'highway' = 'path'")
             interest_filters_sql.append(f"tags @> ${param_idx}") # Check if 'hiking':'yes' exists
             params.append(json.dumps({"hiking": "yes"}))
             param_idx += 1
        if 'beach' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'natural' = 'beach'")
        if 'museum' in user_interests_set or 'history' in user_interests_set or 'art' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'tourism' = 'museum'")
             interest_filters_sql.append(f"tags ->> 'tourism' = 'gallery'")
        if 'castle' in user_interests_set or 'history' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'historic' = 'castle'")
             interest_filters_sql.append(f"tags ->> 'historic' = 'ruins'")
        if 'restaurant' in user_interests_set or 'food' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'amenity' = 'restaurant'")
             interest_filters_sql.append(f"tags ->> 'amenity' = 'food_court'")
        if 'cafe' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'amenity' = 'cafe'")
        if 'bar' in user_interests_set or 'pub' in user_interests_set or 'nightlife' in user_interests_set:
             interest_filters_sql.append(f"tags ->> 'amenity' = 'bar'")
             interest_filters_sql.append(f"tags ->> 'amenity' = 'pub'")
             interest_filters_sql.append(f"tags ->> 'amenity' = 'nightclub'")
        if 'park' in user_interests_set or 'nature' in user_interests_set:
            interest_filters_sql.append(f"tags ->> 'leisure' = 'park'")
            interest_filters_sql.append(f"tags ->> 'leisure' = 'nature_reserve'")

        # Add simple name matching (less efficient without FTS index)
        name_like_pattern = '|'.join(re.escape(intr) for intr in user_interests_set if len(intr) > 2)
        if name_like_pattern:
             interest_filters_sql.append(f"name ILIKE ${param_idx}")
             params.append(f"%{name_like_pattern}%")
             param_idx += 1

        if interest_filters_sql:
            where_clauses.append(f"({ ' OR '.join(interest_filters_sql) })")

    # Combine WHERE clauses
    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)

    # --- 3. Construct UNION ALL Query - ADJUSTED FOR CATEGORY ---
    query_parts = []
    count_query_parts = []
    specific_tag_filter = "" # For category-specific tag filters

    # Determine which tables/tags to query based on the category parameter
    tables_to_target = []
    if category and category in CATEGORY_MAP:
        # Direct match: only query the specified main category table
        tables_to_target = [(category, CATEGORY_MAP[category])]
        logger.info(f"Filtering by primary category: {category}")
    elif category:
        # Handle conceptual categories like 'park'
        logger.info(f"Handling conceptual category: {category}")
        category_lower = category.lower() # Normalize category input
        if category_lower == "park":
            tables_to_target = [("natural_wonder", CATEGORY_MAP["natural_wonder"])]
            specific_tag_filter = f"AND tags ->> 'leisure' = ${param_idx}"
            params.append("park")
            param_idx += 1
        elif category_lower == "beach":
            tables_to_target = [("natural_wonder", CATEGORY_MAP["natural_wonder"])]
            specific_tag_filter = f"AND tags ->> 'natural' = ${param_idx}"
            params.append("beach")
            param_idx += 1
        elif category_lower == "museum":
            tables_to_target = [("landmark", CATEGORY_MAP["landmark"])]
            specific_tag_filter = f"AND tags ->> 'tourism' = ${param_idx}"
            params.append("museum")
            param_idx += 1
        elif category_lower == "castle":
            tables_to_target = [("landmark", CATEGORY_MAP["landmark"])]
            specific_tag_filter = f"AND tags ->> 'historic' = ${param_idx}"
            params.append("castle")
            param_idx += 1
        # Add more elif blocks for other conceptual categories (mountain -> natural=peak, etc.)
        # elif category_lower == "mountain": ...
        else:
            logger.warning(f"Unmapped category '{category}' specified, querying all tables.")
            tables_to_target = CATEGORY_MAP.items()
    else:
        logger.info("No category filter specified, querying all tables.")
        tables_to_target = CATEGORY_MAP.items()

    # Build the query parts based on the targeted tables
    for cat_name_mapped, cat_info in tables_to_target:
        table_name = cat_info["table"]
        base_select_list = "id, name, latitude, longitude, website, description, opening_hours, osm_type, osm_id, tags"
        select_list = "" # Initialize select_list within loop

        # Construct SELECT list with category name and NULLs for non-matching columns
        if table_name == 'landmarks':
             select_list = base_select_list + f", entry_fee, '{cat_name_mapped}' as category, NULL as cuisine"
        elif table_name == 'natural_wonders':
             select_list = base_select_list + f", entry_fee, '{cat_name_mapped}' as category, NULL as cuisine"
        elif table_name == 'restaurants_food':
             select_list = base_select_list + f", NULL as entry_fee, '{cat_name_mapped}' as category, cuisine"
        else:
            logger.warning(f"Skipping unknown table name '{table_name}' in UNION query construction.")
            continue

        # Combine base WHERE clause (location/interests) with specific tag filter
        combined_where_sql = where_sql
        if specific_tag_filter:
            if where_sql: # Already have WHERE clauses? Append with AND
                combined_where_sql += f" {specific_tag_filter}"
            else: # No other WHERE clauses? Start with WHERE
                 # Remove leading 'AND ' from specific_tag_filter if where_sql is empty
                 combined_where_sql = f"WHERE {specific_tag_filter.strip().removeprefix('AND ')}"
        else:
            # Ensure there's a space if where_sql exists but specific_tag_filter doesn't
             combined_where_sql = where_sql


        query_parts.append(f'(SELECT {select_list} FROM "{table_name}" {combined_where_sql})')
        count_query_parts.append(f'(SELECT 1 FROM "{table_name}" {combined_where_sql})')

    if not query_parts:
        logger.warning("No valid query parts generated after category filtering.")
        return [], 0

    # --- 4. Build Count Query ---
    full_count_query = "SELECT COUNT(*) FROM (" + " UNION ALL ".join(count_query_parts) + ") AS count_union"
    logger.debug(f"COUNT Query: {full_count_query}")
    logger.debug(f"COUNT Params: {params}")

    # --- 5. Build Paginated Data Query ---
    order_by_sql = "ORDER BY name NULLS LAST, id" # Keep simple order for now
    # Adjust parameter indices for LIMIT/OFFSET based on final param count
    limit_param_idx = param_idx
    offset_param_idx = param_idx + 1
    limit_offset_sql = f"LIMIT ${limit_param_idx} OFFSET ${offset_param_idx}"
    params_paginated = params + [size, offset] # Add pagination params *last*

    full_data_query = " UNION ALL ".join(query_parts)
    paginated_data_query = f"({full_data_query}) {order_by_sql} {limit_offset_sql}"
    logger.debug(f"DATA Query: {paginated_data_query}")
    logger.debug(f"DATA Params: {params_paginated}")


    # --- 6. Execute Queries ---
    final_items = []
    total_relevant_items = 0
    try:
        # Execute count query first
        total_relevant_items = await conn.fetchval(full_count_query, *params) # Use original params for count
        total_relevant_items = total_relevant_items or 0
        logger.info(f"Total relevant items found matching filters: {total_relevant_items}")

        if total_relevant_items == 0 or offset >= total_relevant_items:
             logger.info("Offset exceeds total items or no items found, skipping data fetch.")
             return [], total_relevant_items

        # Execute data query only if needed
        records = await conn.fetch(paginated_data_query, *params_paginated)
        logger.info(f"Fetched {len(records)} records for page {page}, size {size}.")

        # --- 7. Post-Process Results (Scoring, Distance, Image, Address, Model Conversion) ---
        scored_places = []
        max_score = 10.0 # Keep scoring logic

        for r in records:
            place = dict(r) # Work with a mutable dictionary
            score = 0.0; reasons = []; distance = None
            place['tags'] = _prepare_tags_for_pydantic(place) # Prepare tags first

            # a) Proximity / Distance (Only if location was provided)
            if latitude is not None and longitude is not None:
                lat2, lon2 = place.get('latitude'), place.get('longitude')
                if lat2 is not None and lon2 is not None:
                    distance = calculate_distance_km(latitude, longitude, lat2, lon2)
                    # Optional precise filtering (usually bbox is enough)
                    # if radius_km is not None and distance > radius_km: continue
                    if radius_km and radius_km > 0:
                         proximity_bonus = max(0, (1 - (distance / radius_km))) * (max_score / 2)
                         score += proximity_bonus; reasons.append(f"Nearby ({distance:.1f}km)")
                place['distance_km'] = round(distance, 1) if distance is not None else None
            else:
                 place['distance_km'] = None

            # b) Interest Matching Score
            matched_interests = set(); place_name_lower = str(place.get('name','')).lower(); place_tags = place.get('tags') or {}
            # ... (Keep the logic for checking interests against name/tags) ...
            for interest in user_interests_set:
                if interest in place_name_lower: matched_interests.add(interest); continue
                # Add tag checks...
                if interest == 'beach' and place_tags.get('natural') == 'beach': matched_interests.add(interest)
                elif interest in ['mountain', 'peak', 'hiking'] and place_tags.get('natural') == 'peak': matched_interests.add(interest)
                # ... etc ...
            if matched_interests:
                interest_bonus_per_match = (max_score / 2) / max(1, len(user_interests_set))
                score += len(matched_interests) * interest_bonus_per_match
                reasons.append(f"Matches interests: {', '.join(sorted(list(matched_interests)))}")

            place['relevance_score'] = round(score, 2)
            place['reason'] = reasons if reasons else None

            # c) Extract Image URL
            image_url = None
            if place.get('tags'): # Use the processed dict's tags
                 image_url = place['tags'].get('image') or place['tags'].get('wikimedia_commons')
                 # ... (optional wikimedia format check) ...
            place['image_url'] = image_url

            # d) Construct Address String
            address_parts = []
            tags = place.get('tags') or {} # Use the processed dict's tags
            if tags.get('addr:full'):
                address_parts.append(tags['addr:full'])
            else:
                # Define preferred order
                addr_keys = ['addr:housenumber', 'addr:street', 'addr:city', 'addr:postcode', 'addr:country']
                for key in addr_keys:
                    if tags.get(key):
                        address_parts.append(tags[key])
            place['address'] = ", ".join(part for part in address_parts if part) or None

            scored_places.append(place) # Add the processed dict

        # --- 8. Final Sort (Optional) & Model Conversion ---
        # scored_places.sort(key=lambda p: p['relevance_score'], reverse=True)

        for item_dict in scored_places:
             try:
                 # Ensure all fields expected by RecommendedPlace are present
                 # The SELECT list in the UNION query was designed to provide defaults (NULL)
                 # for missing columns across tables.
                 final_items.append(RecommendedPlace(**item_dict))
             except Exception as e:
                  logger.warning(f"Failed to parse final dict into RecommendedPlace model ID {item_dict.get('id')}: {e}")
                  logger.debug(f"Dict causing failure: {item_dict}")

    except asyncpg.PostgresError as db_error:
        logger.error(f"Database error fetching recommendations for user {user_id}: {db_error}")
        # Return empty on DB error, count might be inaccurate or 0
        return [], total_relevant_items
    except Exception as e:
        logger.exception(f"Unexpected error fetching recommendations for user {user_id}: {e}")
        return [], total_relevant_items # Return empty on other errors

    logger.info(f"Returning {len(final_items)} recommended places for user {user_id} (page {page}, size {size}). Total relevant matching filters: {total_relevant_items}")
    return final_items, total_relevant_items
