import asyncio
import httpx
import logging
import os
import sys
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict, Any

# --- Add project root to path to allow imports from app ---
# Adjust the path depth ('..') based on where you save the script
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, project_root)
# --- End path adjustment ---

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import joinedload

# Import necessary components from your app structure
try:
    from app.db.session import AsyncSessionLocal, engine # Use your session factory
    from app.db import models # Import your models
    from app.core.config import settings # If needed for DB URL or other settings
except ImportError as e:
    print(f"Error importing app components: {e}")
    print("Ensure the script is run from a location where 'app' is importable,")
    print("or adjust the sys.path modification at the top of the script.")
    sys.exit(1)


# --- Logging Setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Wikidata Configuration ---
WIKIDATA_API_URL = "https://www.wikidata.org/w/api.php"
WIKIDATA_SPARQL_URL = "https://query.wikidata.org/sparql" # Alternative if needed
# !! IMPORTANT: Set a descriptive User-Agent !!
HTTP_HEADERS = {
    "User-Agent": "YourTravelAppName/1.0 (contact@youremail.com; script: populate_city_details)"
    # Replace with your app name and contact info
}
# Rate limiting delay between Wikidata API calls (in seconds)
WIKIDATA_DELAY = 1.5 # Be respectful! Increase if you get rate limited.


# --- Helper Functions ---

async def search_wikidata_for_city(city_name: str, country_name: str, client: httpx.AsyncClient) -> Optional[str]:
    """Searches Wikidata for a city QID based on name and country."""
    search_params = {
        "action": "wbsearchentities",
        "format": "json",
        "language": "en",
        "type": "item",
        "limit": 5, # Get a few results to check descriptions
        "search": city_name,
    }
    try:
        response = await client.get(WIKIDATA_API_URL, params=search_params, headers=HTTP_HEADERS, timeout=20.0)
        response.raise_for_status()
        data = response.json()
        results = data.get("search", [])

        if not results:
            logger.warning(f"Wikidata search found no results for: {city_name}, {country_name}")
            return None

        # --- Verification Step: Check description for country ---
        for result in results:
            qid = result.get("id")
            desc = result.get("description", "").lower()
            # Simple check if country name appears in description (adjust logic if needed)
            if country_name.lower() in desc:
                logger.info(f"Found likely Wikidata match for {city_name}, {country_name}: {qid} ('{desc}')")
                return qid
            # Fallback: if only one result, maybe accept it cautiously?
            # elif len(results) == 1:
            #    logger.warning(f"Taking single search result {qid} for {city_name} despite country mismatch in description '{desc}'")
            #    return qid

        logger.warning(f"Wikidata search for {city_name}, {country_name} found results, but none matched country in description.")
        return None # No confident match found

    except httpx.RequestError as e:
        logger.error(f"HTTP error searching Wikidata for '{city_name}': {e}")
        return None
    except Exception as e:
        logger.error(f"Error processing Wikidata search for '{city_name}': {e}", exc_info=True)
        return None

async def get_wikidata_entity_details(qid: str, client: httpx.AsyncClient) -> Optional[Dict[str, Any]]:
    """Fetches details for a specific Wikidata entity (QID)."""
    params = {
        "action": "wbgetentities",
        "ids": qid,
        "format": "json",
        "props": "claims|labels|descriptions", # Get claims (properties), labels, descriptions
        "languages": "en", # Prioritize English
    }
    try:
        response = await client.get(WIKIDATA_API_URL, params=params, headers=HTTP_HEADERS, timeout=20.0)
        response.raise_for_status()
        data = response.json()
        entity = data.get("entities", {}).get(qid)
        if not entity or "claims" not in entity:
             logger.warning(f"Could not get valid entity data for QID: {qid}")
             return None
        return entity
    except httpx.RequestError as e:
        logger.error(f"HTTP error fetching Wikidata entity {qid}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error processing Wikidata entity {qid}: {e}", exc_info=True)
        return None

def extract_property_value(entity_data: Dict[str, Any], property_id: str) -> Optional[Any]:
    """Extracts a specific property value from Wikidata entity claims."""
    claims = entity_data.get("claims", {})
    prop_claims = claims.get(property_id, [])
    if not prop_claims:
        return None

    # Get the first claim statement (often the most relevant)
    mainsnak = prop_claims[0].get("mainsnak")
    if not mainsnak or mainsnak.get("snaktype") != "value":
        return None

    datavalue = mainsnak.get("datavalue")
    if not datavalue:
        return None

    value_type = datavalue.get("type")
    value = datavalue.get("value")

    if value_type == "quantity":
        return value.get("amount") # Returns string, needs conversion
    elif value_type == "wikibase-entityid":
        return value.get("id") # Returns QID or PID
    elif value_type == "time":
        # Format might be like '+2000-01-01T00:00:00Z' - parse if needed
        return value.get("time")
    elif value_type == "monolingualtext":
        return value.get("text")
    elif value_type == "string":
        return value
    # Add handlers for other types like 'globecoordinate' if needed

    return None # Type not handled or value missing

def extract_description(entity_data: Dict[str, Any]) -> Optional[str]:
     """Extracts the English description."""
     descriptions = entity_data.get("descriptions", {})
     en_desc = descriptions.get("en")
     return en_desc.get("value") if en_desc else None

def extract_label(entity_data: Dict[str, Any]) -> Optional[str]:
     """Extracts the English label."""
     labels = entity_data.get("labels", {})
     en_label = labels.get("en")
     return en_label.get("value") if en_label else None

# --- Main Processing Function ---

async def populate_details(max_cities: Optional[int] = None, update_all: bool = False):
    """Fetches details for cities from Wikidata and updates the database."""
    processed_count = 0
    updated_count = 0
    error_count = 0
    cities_to_process: List[models.City] = []

    logger.info("Connecting to database...")
    async with AsyncSessionLocal() as db:
        logger.info("Fetching cities from database...")
        # Select cities needing update (or all if update_all is True)
        stmt = select(models.City).options(joinedload(models.City.country)) # Need country name

        if not update_all:
             # Example: only update if details are NULL or older than 30 days
             thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
             stmt = stmt.where(
                 (models.City.description == None) | # Or other key fields are null
                 (models.City.details_last_updated == None) |
                 (models.City.details_last_updated < thirty_days_ago)
             )

        stmt = stmt.order_by(models.City.id) # Process in a consistent order
        if max_cities:
            stmt = stmt.limit(max_cities)

        result = await db.execute(stmt)
        cities_to_process = result.scalars().unique().all()
        logger.info(f"Found {len(cities_to_process)} cities to process.")

        if not cities_to_process:
            logger.info("No cities require updating.")
            return

        # --- Process Cities ---
        async with httpx.AsyncClient() as client:
            for city in cities_to_process:
                update_data = {}
                processed_count += 1
                city_name = city.name
                country_name = city.country.name if city.country else "Unknown Country"
                logger.info(f"Processing {processed_count}/{len(cities_to_process)}: {city_name}, {country_name} (ID: {city.id})")

                try:
                    # 1. Find Wikidata ID if missing
                    if not city.wikidata_id:
                        logger.info(f"Searching Wikidata ID for {city_name}...")
                        qid = await search_wikidata_for_city(city_name, country_name, client)
                        if qid:
                            update_data["wikidata_id"] = qid
                            city.wikidata_id = qid # Update in memory for next step
                        else:
                            logger.warning(f"Could not find Wikidata ID for {city_name}. Skipping detail fetch.")
                            await asyncio.sleep(WIKIDATA_DELAY) # Still sleep after search attempt
                            continue # Move to next city
                        await asyncio.sleep(WIKIDATA_DELAY) # Delay after search API call
                    else:
                         logger.info(f"Using existing Wikidata ID: {city.wikidata_id}")


                    # 2. Fetch Entity Details using QID
                    if city.wikidata_id:
                        logger.info(f"Fetching Wikidata details for {city.wikidata_id}...")
                        entity_data = await get_wikidata_entity_details(city.wikidata_id, client)

                        if entity_data:
                            # 3. Extract Data
                            description = extract_description(entity_data)
                            if description and description != city.description:
                                update_data["description"] = description
                                logger.info(f"  - Found Description: {' '.join(description.split()[:10])}...") # Log snippet

                            population_str = extract_property_value(entity_data, "P1082") # Population
                            if population_str:
                                try:
                                    population = int(float(population_str)) # Wikidata quantity amount is string
                                    if population != city.population:
                                        update_data["population"] = population
                                        logger.info(f"  - Found Population: {population}")
                                except ValueError:
                                    logger.warning(f"  - Could not parse population: {population_str}")

                            tz_qid = extract_property_value(entity_data, "P421") # Timezone (returns QID)
                            if tz_qid:
                                logger.info(f"  - Found Timezone QID: {tz_qid}. Fetching its label...")
                                await asyncio.sleep(WIKIDATA_DELAY) # Delay before next API call
                                tz_entity_data = await get_wikidata_entity_details(tz_qid, client)
                                if tz_entity_data:
                                    tz_name = extract_label(tz_entity_data) # Get label (e.g., "Asia/Tokyo")
                                    if tz_name and tz_name != city.timezone:
                                        update_data["timezone"] = tz_name
                                        logger.info(f"    - Found Timezone Name: {tz_name}")

                            # ** Best Time/Famous For - Not implemented via auto-fetch **
                            # update_data["best_time_to_travel"] = "..." # Manually add or parse later
                            # update_data["famous_for"] = "..."

                        else:
                            logger.warning(f"Failed to get entity data for {city.wikidata_id}")
                    else:
                         logger.warning(f"Cannot fetch details without Wikidata ID for {city_name}")


                    # 4. Update Database if changes were found
                    if update_data:
                        update_data["details_last_updated"] = datetime.now(timezone.utc)
                        logger.info(f"Updating DB for city ID {city.id} with: {list(update_data.keys())}")
                        stmt_update = update(models.City).where(models.City.id == city.id).values(**update_data)
                        await db.execute(stmt_update)
                        updated_count += 1
                    else:
                        logger.info(f"No updates needed for city ID {city.id}")

                except Exception as e:
                    logger.error(f"Failed processing city {city.id} ({city_name}): {e}", exc_info=True)
                    error_count += 1
                finally:
                    # Rate limiting delay BEFORE the next city's API calls
                    logger.debug(f"Waiting {WIKIDATA_DELAY}s before next city...")
                    await asyncio.sleep(WIKIDATA_DELAY)


        logger.info("Committing database changes...")
        await db.commit()
        logger.info("Database commit complete.")

    logger.info(f"--- Processing Summary ---")
    logger.info(f"Cities Processed: {processed_count}")
    logger.info(f"Cities Updated:   {updated_count}")
    logger.info(f"Errors Encountered: {error_count}")


# --- Script Entry Point ---
if __name__ == "__main__":
    # Basic argument parsing (optional)
    max_cities_arg = None
    update_all_arg = False
    if len(sys.argv) > 1:
        try:
             max_cities_arg = int(sys.argv[1])
             logger.info(f"Running for a maximum of {max_cities_arg} cities.")
        except ValueError:
             if sys.argv[1].lower() == '--all':
                  update_all_arg = True
                  logger.info("Running in update-all mode.")
             else:
                  print(f"Usage: python {sys.argv[0]} [max_cities | --all]")
                  # sys.exit(1) # Allow running without args

    asyncio.run(populate_details(max_cities=max_cities_arg, update_all=update_all_arg))