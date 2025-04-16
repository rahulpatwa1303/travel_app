# app/crud/crud_place.py
import asyncio
import logging
from typing import List, Optional, Dict, Any

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, distinct
from sqlalchemy import func as sql_func
from fastapi import BackgroundTasks
from sqlalchemy.orm import selectinload, joinedload

from app.db import models
from app.schemas import Place as PlaceSchema # Import the schema
from app.core.config import settings
from app.services import wikimedia_service
from app.db.session import AsyncSessionLocal # Import session factory

logger = logging.getLogger(__name__)
# Ensure basicConfig is called somewhere, e.g., in main.py or here for simplicity
# logging.basicConfig(level=logging.INFO)

# --- Background Task Function for Places ---
async def fetch_and_store_place_image_task(place_id: int, place_name: str, category: Optional[str], city_name: Optional[str]):
    """
    Background task to fetch image for a place from Wikimedia and store it.
    Handles its own DB session.
    """
    logger.info(f"BG Task: Fetching image for {place_name} (ID: {place_id})")
    async with AsyncSessionLocal() as db_task:
        try:
            # Check if image already exists
            stmt_check = select(models.PlaceImage).where(models.PlaceImage.place_id == place_id).limit(1)
            existing_image = await db_task.execute(stmt_check)
            if existing_image.scalars().first():
                logger.info(f"BG Task: Image already exists for {place_name} (ID: {place_id}). Skipping.")
                return

            # Fetch from Wikimedia using place details
            fetched_url = await wikimedia_service.get_place_image_url(
                place_name=place_name, category=category, city_name=city_name # Pass relevant details
            )

            if fetched_url:
                logger.info(f"BG Task: Found Wikimedia image for {place_name}: {fetched_url}")
                db_image = models.PlaceImage(place_id=place_id, image_url=fetched_url, source="wikimedia")
                db_task.add(db_image)
                await db_task.commit()
                logger.info(f"BG Task: Successfully stored image for {place_name} (ID: {place_id})")
            else:
                logger.warning(f"BG Task: Could not find Wikimedia image for {place_name} (ID: {place_id})")

        except Exception as e:
            await db_task.rollback()
            logger.error(f"BG task error for place {place_id} ({place_name}): {e}", exc_info=True)

# --- Keep get_distinct_categories ---

async def get_distinct_categories(db: AsyncSession) -> List[str]:
    """
    Retrieves a distinct, sorted list of all place categories
    from the places table, ensuring no None values are returned.
    """
    stmt = select(models.Place.category)\
           .where(models.Place.category.is_not(None), models.Place.category != '')\
           .distinct()\
           .order_by(models.Place.category) # Order alphabetically

    result = await db.execute(stmt)
    categories_from_db = result.scalars().all()

    # --- Add explicit filtering in Python as a safeguard ---
    # Ensure every item is not None before returning
    categories = [str(cat) for cat in categories_from_db if cat is not None]
    # --- End of added filter ---

    logger.info(f"Returning distinct categories: {categories}") # Log the final list
    return categories

# --- Updated get_places function ---
async def get_places(
    db: AsyncSession,
    background_tasks: BackgroundTasks,
    *,
    city_id: Optional[int] = None,
    category: Optional[str] = None,
    q: Optional[str] = None, # <<< Add search query parameter
    # --- Add sorting parameter ---
    sort_by: Optional[str] = None, # e.g., "name_asc", "name_desc", "relevance"
    skip: int = 0,
    limit: int = settings.DEFAULT_PAGE_SIZE
) -> List[Dict[str, Any]]: # Return Dicts matching schema structure
    """
    Retrieves places with filtering, FTS, sorting, and pagination.
    Handles background image fetching.
    """
    logger.info(f"Fetching places: city_id={city_id}, category='{category}', q='{q}', sort='{sort_by}', skip={skip}, limit={limit}")

    stmt = select(models.Place)

    # --- Filtering ---
    city_name_for_wikimedia: Optional[str] = None
    if city_id is not None:
        stmt = stmt.where(models.Place.city_id == city_id)
        city_result = await db.execute(select(models.City.name).where(models.City.id == city_id))
        city_name_for_wikimedia = city_result.scalar_one_or_none()

    if category:
        stmt = stmt.where(sql_func.lower(models.Place.category) == sql_func.lower(category))

    # --- Full-Text Search ---
    search_rank = None # Define variable for potential ranking column
    if q:
        # Use plainto_tsquery for simple query parsing, or websearch_to_tsquery for more flexible syntax
        # Ensure the FTS configuration ('simple' or 'english') matches the one used for the index
        query_ts = sql_func.plainto_tsquery('simple', q)
        # Filter using the @@ operator
        stmt = stmt.where(models.Place.fts_vector.op('@@')(query_ts)) # Use op('@@') for FTS match

        # --- Add Ranking for Relevance Sorting ---
        # Calculate relevance rank only if sorting by relevance
        if sort_by == "relevance":
            search_rank = sql_func.ts_rank(models.Place.fts_vector, query_ts).label("rank")
            # Add the rank column to the selection
            stmt = stmt.add_columns(search_rank)


    # --- Sorting ---
    if sort_by == "relevance" and search_rank is not None:
        stmt = stmt.order_by(search_rank.desc()) # Order by relevance descending
    elif sort_by == "name_asc":
        stmt = stmt.order_by(models.Place.name.asc())
    elif sort_by == "name_desc":
         stmt = stmt.order_by(models.Place.name.desc())
    else: # Default sort
        stmt = stmt.order_by(models.Place.name.asc()) # Default to name ascending


    # --- Pagination ---
    stmt = stmt.offset(skip).limit(limit)

    result = await db.execute(stmt)

    # Process results - handle the case where rank was added
    places: List[models.Place] = []
    if sort_by == "relevance" and search_rank is not None:
         # Result contains tuples (Place, rank)
        for row in result.all():
            places.append(row[0]) # Extract the Place object
    else:
        # Result contains only Place objects
        places = result.scalars().all()


    if not places:
        logger.info("No places found matching criteria.")
        return []

    # --- Image Fetching (same as before) ---
    place_ids = [place.id for place in places]
    logger.info(f"Found {len(places)} places with IDs: {place_ids}")

    stmt_images = select(models.PlaceImage).where(models.PlaceImage.place_id.in_(place_ids))
    result_images = await db.execute(stmt_images)
    images: List[models.PlaceImage] = result_images.scalars().all()
    images_by_place_id: Dict[int, List[str]] = {place_id: [] for place_id in place_ids}
    for image in images:
        if image.place_id in images_by_place_id:
            images_by_place_id[image.place_id].append(str(image.image_url))

    # --- Prepare Response and Trigger BG Tasks (same as before) ---
    places_data = []
    places_missing_images = []
    for place in places:
        place_existing_images = images_by_place_id.get(place.id, [])
        place_dict = {
            "id": place.id,
            "name": place.name,
            "latitude": place.latitude,
            "longitude": place.longitude,
            "category": place.category,
            "address": place.address,
            "city_id": place.city_id,
            "images": place_existing_images[:1]
        }
        places_data.append(place_dict)
        if not place_existing_images:
            places_missing_images.append(place)

    if places_missing_images:
        logger.info(f"Triggering background tasks for {len(places_missing_images)} places missing images.")
        for place_to_fetch in places_missing_images:
            # Need city name context for wikimedia search
            current_city_name = None
            if place_to_fetch.city_id: # Attempt to get city name if city_id exists
                 city_res = await db.execute(select(models.City.name).where(models.City.id == place_to_fetch.city_id))
                 current_city_name = city_res.scalar_one_or_none()

            background_tasks.add_task(
                fetch_and_store_place_image_task,
                place_id=place_to_fetch.id,
                place_name=place_to_fetch.name,
                category=place_to_fetch.category,
                city_name=current_city_name
            )

    logger.info("Finished preparing places list data.")
    return places_data
# --- New function for getting place details ---
async def get_place_details_with_images(
    db: AsyncSession,
    background_tasks: BackgroundTasks,
    place_id: int
) -> Optional[Dict[str, Any]]: # Return dict matching schema structure
    """
    Retrieves details for a single place by ID, fetches existing images,
    and triggers background tasks for missing images.
    """
    logger.info(f"Fetching details for place_id: {place_id}")
    # --- 1. Fetch Place by ID ---
    # Optionally joinload the city if city_name is needed for image search context
    stmt_place = select(models.Place).options(
        joinedload(models.Place.city) # Example: Load city if city_id exists
    ).where(models.Place.id == place_id)

    result_place = await db.execute(stmt_place)
    place: Optional[models.Place] = result_place.scalars().first()

    if not place:
        logger.warning(f"Place with id {place_id} not found.")
        return None # Place not found

    # --- 2. Fetch Existing Images (Batch Query - only one ID here) ---
    stmt_images = select(models.PlaceImage).where(models.PlaceImage.place_id == place.id)
    # Optionally order images (e.g., featured first)
    # stmt_images = stmt_images.order_by(models.PlaceImage.is_featured.desc(), models.PlaceImage.created_at)
    result_images = await db.execute(stmt_images)
    images: List[models.PlaceImage] = result_images.scalars().all()

    image_urls = [str(img.image_url) for img in images] # Extract URLs
    logger.info(f"Found {len(image_urls)} existing images for place {place_id}.")

    # --- 3. Trigger Background Task if No Images Found ---
    if not image_urls:
        logger.info(f"No existing images found for place {place_id}. Triggering background task.")
        # Extract city name if loaded and available
        city_name_context = place.city.name if place.city else None
        background_tasks.add_task(
            fetch_and_store_place_image_task, # Reuse the same task function
            place_id=place.id,
            place_name=place.name,
            category=place.category,
            city_name=city_name_context
        )

    # --- 4. Prepare Response Data ---
    # Convert the SQLAlchemy model object to a dictionary.
    # Pydantic's from_orm can handle this well, but doing it manually
    # gives more control, especially adding the images list.
    place_data = {
        "id": place.id,
        "name": place.name,
        "latitude": place.latitude,
        "longitude": place.longitude,
        "category": place.category,
        "address": place.address,
        "city_id": place.city_id,
        "osm_id": place.osm_id,
        "osm_type": place.osm_type,
        "website": place.website,
        "description": place.description,
        "phone": place.phone,
        "opening_hours": place.opening_hours,
        "cuisine": place.cuisine,
        "entry_fee": place.entry_fee,
        "religion": place.religion,
        "denomination": place.denomination,
        "attributes": place.attributes,
        "created_at": place.created_at,
        "updated_at": place.updated_at,
        "images": image_urls # Add the list of fetched image URLs
    }

    return place_data