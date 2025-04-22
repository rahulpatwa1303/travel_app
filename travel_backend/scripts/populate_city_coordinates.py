# scripts/populate_city_coordinates.py
# Finds lat/lon for cities using geopy/GeoNames and updates the DB.

import asyncio
import logging
import os
import sys
import time # For delays
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any, Tuple

# --- Geopy Imports ---
try:
    from geopy import geocoders
    from geopy.exc import GeocoderTimedOut, GeocoderServiceError, GeocoderQueryError
except ImportError:
    print("Error: 'geopy' library not found. Please install it: pip install geopy")
    sys.exit(1)

# --- Add project root to path ---
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# --- Import app components ---
try:
    from sqlalchemy.ext.asyncio import AsyncSession
    from sqlalchemy import select, update
    from sqlalchemy.orm import joinedload
    from sqlalchemy.exc import SQLAlchemyError
    from app.db.session import AsyncSessionLocal, engine
    from app.db import models
    from app.core.config import settings # Import settings to get username
except ImportError as e:
    print(f"Error importing app components: {e}")
    sys.exit(1)

# --- Logging Setup ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("populate_city_coords")

# --- GeoNames Configuration ---
GEONAMES_DELAY = 1.0 # Seconds between GeoNames API calls (adjust based on limits)
GEONAMES_TIMEOUT = 10 # Timeout for each geocode request

# --- Geocoder Initialization ---
if not settings.GEONAMES_USERNAME:
    logger.error("GEONAMES_USERNAME not found in environment settings (.env file). Please register at geonames.org and set the variable.")
    sys.exit(1)

try:
    # Note: geopy operations are typically synchronous. We'll run them sequentially with delays.
    # If performance becomes critical, explore async geocoding libraries or run this in threads.
    gn = geocoders.GeoNames(username=settings.GEONAMES_USERNAME)
    logger.info(f"GeoNames geocoder initialized with user: {settings.GEONAMES_USERNAME}")
except Exception as e:
    logger.error(f"Failed to initialize GeoNames geocoder: {e}")
    sys.exit(1)


# ================================
# --- Geocoding Helper ---
# ================================
def get_coordinates_for_city(city_name: str, country_name: Optional[str]) -> Optional[Tuple[float, float]]:
    """Uses GeoNames to find coordinates for a city, using country for disambiguation."""
    query = f"{city_name}"
    if country_name:
        query += f", {country_name}"
    logger.debug(f"Geocoding query: '{query}'")

    try:
        location = gn.geocode(query, exactly_one=True, timeout=GEONAMES_TIMEOUT)
        if location:
            logger.debug(f"Found location: {location.address} -> ({location.latitude}, {location.longitude})")
            # Add check? Does location.address roughly match input?
            return (location.latitude, location.longitude)
        else:
            logger.warning(f"GeoNames found no location for query: '{query}'")
            return None
    except GeocoderTimedOut:
        logger.error(f"GeoNames timeout for query: '{query}'")
        return None
    except GeocoderQueryError as q_err: # Specific error for bad queries
         logger.error(f"GeoNames query error for '{query}': {q_err}")
         return None
    except GeocoderServiceError as s_err:
        logger.error(f"GeoNames service error for query '{query}': {s_err}")
        # Consider adding retries here if appropriate
        return None
    except Exception as e:
        logger.error(f"Unexpected error geocoding '{query}': {e}", exc_info=True)
        return None

# ==================================
# --- Main Processing Function ---
# ==================================
async def populate_coordinates(max_cities: Optional[int] = None, update_all: bool = False):
    """Fetches coordinates for cities missing them and updates the database."""
    start_time = datetime.now()
    processed_count = 0
    updated_db_count = 0
    geocode_success_count = 0
    geocode_fail_count = 0
    cities_to_process: List[models.City] = []

    logger.info("Starting city coordinate population process...")
    logger.info(f"Mode: {'Update All' if update_all else 'Update Missing Only'}")
    if max_cities: logger.info(f"Maximum cities to process: {max_cities}")

    # --- Get Cities from DB ---
    logger.info("Connecting to database and fetching cities...")
    async with AsyncSessionLocal() as db_fetch:
        stmt = select(models.City).options(joinedload(models.City.country)).order_by(models.City.id)
        if not update_all:
            # Only fetch cities where lat or lon is NULL
            stmt = stmt.where(
                (models.City.latitude == None) | (models.City.longitude == None) # noqa E711
            )
        if max_cities: stmt = stmt.limit(max_cities)

        result = await db_fetch.execute(stmt)
        cities_to_process = result.scalars().unique().all()

    total_cities_to_process = len(cities_to_process)
    logger.info(f"Fetched {total_cities_to_process} cities to process.")
    if not cities_to_process: return

    # --- Process Cities One by One ---
    for city in cities_to_process:
        processed_count += 1
        city_name = city.name
        country_name = city.country.name if city.country else None
        logger.info(f"--- Processing {processed_count}/{total_cities_to_process}: {city_name} (ID: {city.id}) ---")

        update_payload: Dict[str, Any] = {}
        coords: Optional[Tuple[float, float]] = None

        # Delay *before* calling the geocoder
        logger.debug(f"Waiting {GEONAMES_DELAY}s before geocoding...")
        time.sleep(GEONAMES_DELAY) # Use time.sleep as geopy is sync

        try:
            # --- 1. Geocode City ---
            coords = get_coordinates_for_city(city_name, country_name)

            if coords:
                geocode_success_count += 1
                latitude, longitude = coords
                # Only add to payload if coords actually changed (or were NULL)
                if city.latitude != latitude or city.longitude != longitude:
                    update_payload["latitude"] = latitude
                    update_payload["longitude"] = longitude
            else:
                geocode_fail_count += 1
                logger.warning(f"Failed to geocode {city_name}. Skipping coordinate update.")


            # --- 2. Update Database for THIS City (if coords found and changed) ---
            if update_payload:
                try:
                    async with AsyncSessionLocal() as db_update:
                        logger.info(f"Updating DB for city ID {city.id} with coordinates: ({update_payload.get('latitude')}, {update_payload.get('longitude')})")
                        stmt_update = update(models.City).where(models.City.id == city.id).values(**update_payload)
                        await db_update.execute(stmt_update)
                        await db_update.commit()
                        updated_db_count += 1
                except SQLAlchemyError as db_err:
                     logger.error(f"Database update failed for city {city.id}: {db_err}", exc_info=True)
                     # await db_update.rollback() # Handled by context manager
                     geocode_fail_count +=1 # Count as failure if DB update fails
                except Exception as e_upd:
                     logger.error(f"Unexpected error during DB update for city {city.id}: {e_upd}", exc_info=True)
                     geocode_fail_count +=1
            else:
                logger.info(f"No coordinate update needed for city ID {city.id} (either failed geocode or coords unchanged).")

        except Exception as e:
             logger.error(f"!! Unhandled error processing city {city.id} ({city_name}): {e}", exc_info=True)
             geocode_fail_count += 1 # Count unexpected errors as geocode fails

    # --- Final Summary ---
    end_time = datetime.now()
    duration = end_time - start_time
    logger.info(f"--- Coordinate Population Finished ---")
    logger.info(f"Duration: {duration}")
    logger.info(f"Total Cities Considered: {total_cities_to_process}")
    logger.info(f"Cities Processed in Loop: {processed_count}")
    logger.info(f"Geocoding Successful: {geocode_success_count}")
    logger.info(f"Geocoding Failed/Skipped: {geocode_fail_count}")
    logger.info(f"Cities Updated in DB: {updated_db_count}")


# --- Script Entry Point ---
if __name__ == "__main__":
    max_cities_arg = None
    update_all_arg = False # Default: only update missing
    if len(sys.argv) > 1:
        for arg in sys.argv[1:]:
            if arg.lower() == '--all':
                 update_all_arg = True
                 logger.info("Running with --all: Will attempt to geocode ALL cities.")
            else:
                 try:
                     max_cities_arg = int(arg)
                     logger.info(f"Running for a maximum of {max_cities_arg} cities.")
                 except ValueError:
                     print(f"Usage: python {sys.argv[0]} [max_cities] [--all]")

    try:
        # Note: Since geopy is sync, the async nature here only applies to DB access.
        # Geocoding calls will happen sequentially with delays.
        asyncio.run(populate_coordinates(max_cities=max_cities_arg, update_all=update_all_arg))
    except KeyboardInterrupt: logger.info("Script interrupted by user.")
    except Exception as e: logger.critical(f"Script failed: {e}", exc_info=True)