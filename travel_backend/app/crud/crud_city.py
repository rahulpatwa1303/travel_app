import logging
from typing import Any, Dict, List, Optional

from fastapi import BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload # Use selectinload for efficient async relationship loading
from sqlalchemy import func as sql_func
from app.db import models # Import models namespace
from app.core.config import settings
from app.db.session import AsyncSessionLocal
from app.services import wikimedia_service # For pagination defaults if needed later

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO) # Configure basic logging

async def get_city_images_from_db(db: AsyncSession, city_id: int, limit: int = 1) -> List[str]:
    """Helper to fetch image URLs for a city from the DB."""
    stmt = select(models.CityImage.image_url).where(models.CityImage.city_id == city_id).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()

async def add_city_image_to_db(db: AsyncSession, city_id: int, image_url: str):
    """Helper to add a fetched image URL to the DB."""
    db_image = models.CityImage(city_id=city_id, image_url=image_url, source="wikimedia")
    db.add(db_image)
    # Note: Commit is handled by the main request lifecycle (get_db dependency)
    # For background tasks, you'd need explicit commit/session management.

async def get_popular_cities_optimized( # Renamed
    db: AsyncSession,
    background_tasks: BackgroundTasks, # Accept background tasks object
    *,
    country_name: Optional[str] = None,
    skip: int = 0,
    limit: int = settings.DEFAULT_PAGE_SIZE
) -> List[Dict[str, Any]]: # Return dicts matching schema structure
    """
    Retrieves popular cities, fetches existing images efficiently (one query),
    and triggers background tasks to fetch missing images.
    """
    logger.info(f"Fetching popular cities: country='{country_name}', skip={skip}, limit={limit}")
    # --- 1. Fetch Cities with Countries ---
    stmt_cities = select(models.City).options(
        selectinload(models.City.country) # Eager load country
    )
    if country_name:
        # Use case-insensitive matching on the joined Country table
        stmt_cities = stmt_cities.join(models.City.country).where(
            sql_func.lower(models.Country.name).contains(sql_func.lower(country_name))
            # Or use ilike: models.Country.name.ilike(f"%{country_name}%")
       )
    stmt_cities = stmt_cities.order_by(models.City.name).offset(skip).limit(limit)

    result_cities = await db.execute(stmt_cities)
    cities: List[models.City] = result_cities.scalars().unique().all()

    if not cities:
        logger.info("No popular cities found matching criteria.")
        return [] # Return empty list if no cities found

    city_ids = [city.id for city in cities]
    logger.info(f"Found {len(cities)} cities with IDs: {city_ids}")

    # --- 2. Fetch Existing Images for these Cities (Batch Query) ---
    stmt_images = select(models.CityImage).where(models.CityImage.city_id.in_(city_ids))
    # If you want only ONE (e.g., featured) image per city, add filtering/ranking here
    # Example: .where(models.CityImage.is_featured == True)
    # Or use DISTINCT ON or ROW_NUMBER in more complex scenarios if needed.
    # For now, fetches all images and we'll take the first one later if needed.

    result_images = await db.execute(stmt_images)
    images: List[models.CityImage] = result_images.scalars().all()

    # --- 3. Map Images to Cities for efficient lookup ---
    images_by_city_id: Dict[int, List[str]] = {city_id: [] for city_id in city_ids}
    for image in images:
        if image.city_id in images_by_city_id:
             # Append image_url as string
            images_by_city_id[image.city_id].append(str(image.image_url))
    logger.info(f"Found existing images for city IDs: {[cid for cid, imgs in images_by_city_id.items() if imgs]}")


    # --- 4. Prepare Response Data and Trigger Background Tasks ---
    cities_data = []
    cities_missing_images = [] # Keep track to trigger tasks later

    for city in cities:
        city_existing_images = images_by_city_id.get(city.id, [])

        # Prepare data structure matching the Pydantic schema
        city_dict = {
            "id": city.id,
            "name": city.name,
            "country": {
                 "id": city.country.id,
                 "name": city.country.name
            },
            # Use only the first image found for simplicity in the list view
            "images": city_existing_images[:1] # Take up to 1 image URL
        }
        cities_data.append(city_dict)

        # Check if image needs fetching
        if not city_existing_images:
            cities_missing_images.append(city) # Add the full city object

    # --- 5. Add Background Tasks for Cities Missing Images ---
    if cities_missing_images:
        logger.info(f"Triggering background tasks for {len(cities_missing_images)} cities missing images.")
        for city_to_fetch in cities_missing_images:
            background_tasks.add_task(
                fetch_and_store_city_image_task,
                city_id=city_to_fetch.id,
                city_name=city_to_fetch.name,
                country_name=city_to_fetch.country.name # Assumes country is loaded
            )

    logger.info("Finished preparing popular cities data.")
    return cities_data
async def fetch_and_store_city_image_task(city_id: int, city_name: str, country_name: str):
    """
    Background task to fetch image from Wikimedia and store it in the DB.
    Handles its own DB session.
    """
    logger.info(f"Background task started: Fetching image for {city_name} (ID: {city_id})")
    # Create a new independent session for this background task
    async with AsyncSessionLocal() as db_task:
        try:
            # Check if image already exists (in case multiple tasks run concurrently)
            stmt_check = select(models.CityImage).where(models.CityImage.city_id == city_id).limit(1)
            existing_image = await db_task.execute(stmt_check)
            if existing_image.scalars().first():
                logger.info(f"Background task: Image already exists for {city_name} (ID: {city_id}). Skipping fetch.")
                return # Exit if image was added by another task already

            # Fetch from Wikimedia
            fetched_url = await wikimedia_service.get_city_image_url(city_name, country_name)

            if fetched_url:
                logger.info(f"Background task: Found Wikimedia image for {city_name}: {fetched_url}")
                # Store the fetched image URL
                db_image = models.CityImage(city_id=city_id, image_url=fetched_url, source="wikimedia")
                db_task.add(db_image)
                await db_task.commit() # Commit the changes within this session
                logger.info(f"Background task: Successfully stored image for {city_name} (ID: {city_id})")
            else:
                logger.warning(f"Background task: Could not find Wikimedia image for {city_name} (ID: {city_id})")

        except Exception as e:
            await db_task.rollback() # Rollback on error
            logger.error(f"Background task error for city {city_id} ({city_name}): {e}", exc_info=True)
        finally:
            # Session is automatically closed by 'async with'
            pass

