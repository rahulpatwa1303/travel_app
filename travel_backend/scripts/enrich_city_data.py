# scripts/enrich_city_data.py
# (Combines Wikidata fetching and Ollama LLM description generation)

import asyncio
import httpx
import logging
import os
import sys
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict, Any

# --- OpenAI library for easier interaction with Ollama's compatible API ---
# Requires: pip install openai
try:
    from openai import AsyncOpenAI, OpenAIError
except ImportError:
    print("Error: 'openai' library not found. Please install it: pip install openai")
    sys.exit(1)

# --- Add project root to path to allow imports from app ---
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if project_root not in sys.path:
      sys.path.insert(0, project_root)
# --- End path adjustment ---

# --- Import app components ---
try:
    from sqlalchemy.ext.asyncio import AsyncSession
    from sqlalchemy import select, update
    from sqlalchemy.orm import joinedload
    from app.db.session import AsyncSessionLocal, engine # Use your session factory
    from app.db import models # Import your models
    # from app.core.config import settings # Optional: if needed for DB URL etc.
except ImportError as e:
    print(f"Error importing app components: {e}")
    print("Ensure the script is run from a location where 'app' is importable,")
    print("or adjust the sys.path modification at the top of the script.")
    sys.exit(1)

# --- Logging Setup ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)] # Ensure logs go to stdout
)
logger = logging.getLogger("enrich_city_data") # Give logger a specific name

# --- Configuration ---

# Wikidata Configuration
WIKIDATA_API_URL = "https://www.wikidata.org/w/api.php"
WIKIDATA_SPARQL_URL = "https://query.wikidata.org/sparql"
# !! IMPORTANT: Set YOUR descriptive User-Agent !!
HTTP_HEADERS = {
    "User-Agent": "YourTravelAppName/1.0 (contact@youremail.com; script: enrich_city_data)"
    # Replace with your app name and contact info
}
WIKIDATA_API_DELAY = 1.5 # Delay between Wikidata API calls (seconds)

# Wikipedia Configuration
WIKIPEDIA_API_URL = "https://en.wikipedia.org/w/api.php"
WIKIPEDIA_API_DELAY = 0.5 # Shorter delay okay for Wikipedia API usually

# Ollama / LLM Configuration
# --- !! CHOOSE ONE and REPLACE if needed !! ---
# If running Ollama on the SAME machine as the script:
OLLAMA_BASE_URL = "http://192.168.29.200:8080/v1"
# If running Ollama on ANOTHER machine on SAME network:
# OLLAMA_BASE_URL = "http://<Ollama_Machine_IP>:11434/v1"
# If using ngrok (Update URL):
# OLLAMA_BASE_URL = "https://your-random-string.ngrok.io/v1"

OLLAMA_API_KEY = "ollama" # Placeholder, openai lib requires one but ollama ignores it
LLM_MODEL = "mistral:latest" # Ollama model to use
LLM_TIMEOUT = 120.0 # Timeout for LLM calls (might need longer for local models)
LLM_MAX_RETRIES = 2
LLM_RETRY_DELAY = 5 # Seconds to wait before retrying LLM call

# --- Initialize OpenAI Client pointing to Ollama ---
try:
    client_llm = AsyncOpenAI(
        base_url=OLLAMA_BASE_URL,
        api_key=OLLAMA_API_KEY,
        timeout=LLM_TIMEOUT,
        max_retries=0 # We handle retries manually below for more control
    )
except Exception as e:
    logger.error(f"Failed to initialize OpenAI client for Ollama: {e}")
    sys.exit(1)

# ==================================
# --- Wikidata Helper Functions ---
# ==================================
async def search_wikidata_for_city(city_name: str, country_name: str, client: httpx.AsyncClient) -> Optional[str]:
    """Searches Wikidata for a city QID based on name and country."""
    search_params = {
        "action": "wbsearchentities", "format": "json", "language": "en",
        "type": "item", "limit": 5, "search": city_name,
    }
    logger.debug(f"Wikidata searching for: '{city_name}, {country_name}'")
    try:
        response = await client.get(WIKIDATA_API_URL, params=search_params, headers=HTTP_HEADERS, timeout=20.0)
        response.raise_for_status()
        data = response.json()
        results = data.get("search", [])
        if not results: return None

        # Verification Step: Check description for country
        for result in results:
            qid = result.get("id")
            desc = result.get("description", "").lower()
            # Basic check - improve if needed (e.g., check P17 country property)
            if country_name.lower() in desc:
                logger.debug(f"Found likely QID match: {qid} ('{desc}')")
                return qid
        logger.debug(f"No result description matched country '{country_name}'.")
        return None
    except httpx.TimeoutException:
        logger.error(f"Timeout searching Wikidata for '{city_name}'")
        return None
    except httpx.RequestError as e:
        logger.error(f"HTTP error searching Wikidata for '{city_name}': {e}")
        return None
    except Exception as e:
        logger.error(f"Error processing Wikidata search for '{city_name}': {e}")
        return None

async def get_wikidata_entity_details(qid: str, client: httpx.AsyncClient) -> Optional[Dict[str, Any]]:
    """Fetches details for a specific Wikidata entity (QID)."""
    params = {
        "action": "wbgetentities", "ids": qid, "format": "json",
        "props": "claims|labels|descriptions", "languages": "en",
    }
    logger.debug(f"Fetching Wikidata entity details for: {qid}")
    try:
        response = await client.get(WIKIDATA_API_URL, params=params, headers=HTTP_HEADERS, timeout=20.0)
        response.raise_for_status()
        data = response.json()
        entity = data.get("entities", {}).get(qid)
        if not entity or "claims" not in entity: return None
        return entity
    except httpx.TimeoutException:
        logger.error(f"Timeout fetching Wikidata entity {qid}")
        return None
    except httpx.RequestError as e:
        logger.error(f"HTTP error fetching Wikidata entity {qid}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error processing Wikidata entity {qid}: {e}")
        return None

def extract_property_value(entity_data: Dict[str, Any], property_id: str) -> Optional[Any]:
    """Extracts a specific property value from Wikidata entity claims."""
    # ... (keep implementation from previous response) ...
    claims = entity_data.get("claims", {})
    prop_claims = claims.get(property_id, [])
    if not prop_claims: return None
    mainsnak = prop_claims[0].get("mainsnak")
    if not mainsnak or mainsnak.get("snaktype") != "value": return None
    datavalue = mainsnak.get("datavalue")
    if not datavalue: return None
    value_type = datavalue.get("type")
    value = datavalue.get("value")
    if value_type == "quantity": return value.get("amount")
    elif value_type == "wikibase-entityid": return value.get("id")
    elif value_type == "time": return value.get("time")
    elif value_type == "monolingualtext": return value.get("text")
    elif value_type == "string": return value
    return None

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

# ====================================
# --- Wikipedia Helper Functions ---
# ====================================
async def get_wikipedia_intro(city_name: str, country_name: str, client_http: httpx.AsyncClient) -> Optional[str]:
    """Fetches the intro section plain text from English Wikipedia."""
    search_term = f"{city_name}" # Often works better than "City, Country" for title lookup
    logger.debug(f"Fetching Wikipedia intro for: {search_term}")
    params = {
        "action": "query", "format": "json", "titles": search_term,
        "prop": "extracts", "exintro": True, "explaintext": True,
        "redirects": 1, "origin": "*", # origin=* might be needed sometimes
    }
    try:
        response = await client_http.get(WIKIPEDIA_API_URL, params=params, headers=HTTP_HEADERS, timeout=15.0)
        response.raise_for_status()
        data = response.json()
        pages = data.get("query", {}).get("pages", {})
        if pages:
            page_id = list(pages.keys())[0]
            if page_id != "-1":
                extract = pages[page_id].get("extract")
                if extract and len(extract) > 10: # Basic sanity check
                    logger.debug(f"Found Wikipedia intro for {city_name} (length {len(extract)}).")
                    return extract.strip()
        logger.debug(f"Wikipedia intro not found for {city_name}.")
        return None
    except httpx.TimeoutException:
         logger.error(f"Timeout fetching Wikipedia intro for {city_name}")
         return None
    except Exception as e:
        logger.error(f"Error fetching Wikipedia intro for {city_name}: {e}")
        return None

# ================================
# --- LLM Helper Functions ---
# ================================
async def generate_description_with_llm(
    city_name: str,
    country_name: str,
    wikidata_desc: Optional[str],
    wikipedia_intro: Optional[str]
    # Add famous_for etc. if/when scraped
) -> Optional[str]:
    """Generates a city description using the configured LLM."""
    logger.debug(f"Attempting LLM description generation for {city_name}...")

    context = f"City Name: {city_name}\nCountry: {country_name}\n"
    if wikidata_desc: context += f"Wikidata Description: {wikidata_desc}\n"
    if wikipedia_intro:
        intro_snippet = (wikipedia_intro[:700] + '...') if len(wikipedia_intro) > 700 else wikipedia_intro
        context += f"Wikipedia Intro Snippet: {intro_snippet}\n"
    # if famous_for: context += f"Known For: {famous_for}\n"

    if not wikidata_desc and not wikipedia_intro:
        logger.warning(f"Skipping LLM for {city_name}: Insufficient input context.")
        return None

    prompt = f"""
You are a concise travel writer creating content for a mobile app.
Based *only* on the information provided below, write an engaging description for a travel app user.
The description should be 1-2 paragraphs and strictly **maximum 150 words**.
Focus on what makes the city interesting to visit according to the input.
Do not add information not present in the input. If input is minimal, keep the description brief.

Input Information:
---
{context.strip()}
---

Generated Description (max 150 words):
    """

    for attempt in range(LLM_MAX_RETRIES + 1):
        try:
            response = await client_llm.chat.completions.create(
                model=LLM_MODEL,
                messages=[
                    {"role": "system", "content": "You are a concise travel writer for a mobile app."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=250, # Max tokens for the output generation itself
                temperature=0.6, # Slightly lower temp for more factual tone
                timeout=LLM_TIMEOUT # Use configured timeout
            )
            generated_text = response.choices[0].message.content.strip()

            # Basic validation
            if not generated_text:
                 logger.warning(f"LLM returned empty description for {city_name} on attempt {attempt+1}")
                 generated_text = None # Treat empty as failure for retry
                 raise OpenAIError("Empty response received") # Force retry mechanism

            # Optional: Word count check (rough estimate)
            word_count = len(generated_text.split())
            if word_count > 180: # Allow some leeway over 150 target
                 logger.warning(f"LLM description for {city_name} exceeded word count ({word_count}). Truncating or retrying might be needed if strict.")
                 # generated_text = " ".join(generated_text.split()[:150]) + "..." # Example truncation

            logger.info(f"LLM generated description for {city_name} (length: {len(generated_text)}, words: ~{word_count}).")
            return generated_text # Success

        except Exception as e:
            logger.error(f"Error calling LLM API for {city_name} (Attempt {attempt+1}/{LLM_MAX_RETRIES+1}): {e}")
            if attempt < LLM_MAX_RETRIES:
                logger.info(f"Retrying LLM call after {LLM_RETRY_DELAY}s...")
                await asyncio.sleep(LLM_RETRY_DELAY)
            else:
                logger.error(f"LLM call failed after {LLM_MAX_RETRIES+1} attempts for {city_name}.")
                return None # Failed after retries
    return None # Should not be reached, but safety net

# ==================================
# --- Main Processing Function ---
# ==================================
async def enrich_data(max_cities: Optional[int] = None, update_all: bool = False):
    """Fetches details for cities from Wikidata/Wikipedia/LLM and updates the database."""
    processed_count = 0
    updated_count = 0
    skipped_llm_count = 0
    error_count = 0
    cities_to_process: List[models.City] = []

    logger.info("Starting city enrichment process...")
    logger.info(f"Mode: {'Update All' if update_all else 'Update Missing/Old'}")
    if max_cities: logger.info(f"Maximum cities to process: {max_cities}")

    logger.info("Connecting to database...")
    async with AsyncSessionLocal() as db:
        logger.info("Fetching cities from database...")
        stmt = select(models.City).options(joinedload(models.City.country))

        if not update_all:
             thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
             stmt = stmt.where(
                 (models.City.description == None) |
                 (models.City.wikidata_id == None) | # Also fetch if wikidata_id is missing
                 (models.City.details_last_updated == None) |
                 (models.City.details_last_updated < thirty_days_ago)
             )

        stmt = stmt.order_by(models.City.id)
        if max_cities: stmt = stmt.limit(max_cities)

        result = await db.execute(stmt)
        cities_to_process = result.scalars().unique().all()
        logger.info(f"Found {len(cities_to_process)} cities to process.")
        if not cities_to_process: return

        # --- Process Cities ---
        async with httpx.AsyncClient(headers=HTTP_HEADERS, timeout=30.0) as client_http:
            for city in cities_to_process:
                processed_count += 1
                city_name = city.name
                country_name = city.country.name if city.country else "Unknown Country"
                logger.info(f"--- Processing {processed_count}/{len(cities_to_process)}: {city_name}, {country_name} (ID: {city.id}) ---")

                update_data: Dict[str, Any] = {}
                wikidata_description: Optional[str] = city.description # Start with current value
                wiki_intro: Optional[str] = None
                current_wikidata_id: Optional[str] = city.wikidata_id

                try:
                    # 1. Wikidata ID & Details Fetching
                    if not current_wikidata_id:
                        logger.info("Searching Wikidata ID...")
                        qid = await search_wikidata_for_city(city_name, country_name, client_http)
                        await asyncio.sleep(WIKIDATA_API_DELAY) # Delay after search
                        if qid:
                            update_data["wikidata_id"] = qid
                            current_wikidata_id = qid
                        else:
                            logger.warning("Could not find Wikidata ID. Skipping Wikidata detail fetch.")
                    else:
                        logger.info(f"Using existing Wikidata ID: {current_wikidata_id}")

                    if current_wikidata_id:
                        logger.info(f"Fetching Wikidata details for {current_wikidata_id}...")
                        entity_data = await get_wikidata_entity_details(current_wikidata_id, client_http)
                        await asyncio.sleep(WIKIDATA_API_DELAY) # Delay after details fetch

                        if entity_data:
                            # Extract Wikidata Description (use as base or fallback)
                            wd_desc = extract_description(entity_data)
                            if wd_desc:
                                wikidata_description = wd_desc # Update our variable
                                # Decide if we update DB description with WD desc now or wait for LLM
                                # Let's tentatively put it in update_data, LLM might overwrite it
                                if wd_desc != city.description: update_data["description"] = wd_desc
                                logger.info(f"  - Got Wikidata Description: {' '.join(wd_desc.split()[:10])}...")

                            # Extract Population
                            pop_str = extract_property_value(entity_data, "P1082")
                            if pop_str:
                                try:
                                    population = int(float(pop_str))
                                    if population != city.population: update_data["population"] = population
                                    logger.info(f"  - Got Population: {population}")
                                except ValueError: logger.warning(f"  - Could not parse population: {pop_str}")

                            # Extract Timezone
                            tz_qid = extract_property_value(entity_data, "P421")
                            if tz_qid:
                                logger.info(f"  - Got Timezone QID: {tz_qid}. Fetching label...")
                                await asyncio.sleep(WIKIDATA_API_DELAY)
                                tz_entity_data = await get_wikidata_entity_details(tz_qid, client_http)
                                if tz_entity_data:
                                    tz_name = extract_label(tz_entity_data)
                                    if tz_name and tz_name != city.timezone: update_data["timezone"] = tz_name
                                    logger.info(f"    - Got Timezone Name: {tz_name}")
                                await asyncio.sleep(WIKIDATA_API_DELAY) # Delay after TZ label fetch

                        else: logger.warning(f"Failed to get entity data for {current_wikidata_id}")
                    else: logger.warning("Cannot fetch Wikidata details without QID.")

                    # 2. Wikipedia Intro Fetch (Optional)
                    logger.info("Fetching Wikipedia intro...")
                    wiki_intro = await get_wikipedia_intro(city_name, country_name, client_http)
                    await asyncio.sleep(WIKIPEDIA_API_DELAY) # Delay after wikipedia fetch

                    # 3. Advanced Scraping (Placeholder)
                    # scraped_famous_for = await scrape_famous_for(...)
                    # scraped_best_time = await scrape_best_time(...)
                    # if scraped_famous_for: update_data['famous_for'] = scraped_famous_for
                    # if scraped_best_time: update_data['best_time_to_travel'] = scraped_best_time
                    # Remember delays after scraping calls

                    # 4. LLM Description Generation
                    # Generate if current description is missing or too short
                    should_generate_desc = not update_data.get("description", city.description) or len(update_data.get("description", city.description) or "") < 50

                    if should_generate_desc:
                         llm_description = await generate_description_with_llm(
                             city_name=city_name, country_name=country_name,
                             wikidata_desc=wikidata_description, # Use WD desc as input
                             wikipedia_intro=wiki_intro
                             # famous_for=scraped_famous_for
                         )
                         if llm_description:
                             # Overwrite description in update_data if LLM succeeded
                             update_data["description"] = llm_description
                         else:
                            logger.warning(f"LLM generation failed for {city_name}. Keeping previous description if any.")
                            # Remove description from update_data if LLM failed but WD put something in
                            if "description" in update_data and update_data["description"] == wikidata_description:
                                del update_data["description"]
                    else:
                        logger.info(f"Skipping LLM description generation for {city_name}.")
                        skipped_llm_count += 1


                    # 5. Update Database
                    if update_data:
                        update_data["details_last_updated"] = datetime.now(timezone.utc)
                        logger.info(f"Updating DB for city ID {city.id} with keys: {list(update_data.keys())}")
                        stmt_update = update(models.City).where(models.City.id == city.id).values(**update_data)
                        await db.execute(stmt_update)
                        updated_count += 1
                    else:
                        logger.info(f"No database updates needed for city ID {city.id}")

                except Exception as e:
                    logger.error(f"!! Unhandled error processing city {city.id} ({city_name}): {e}", exc_info=True)
                    error_count += 1
                # No finally block needed for delay, handled within loop before potential continue/error


        logger.info("Committing database changes...")
        await db.commit()
        logger.info("Database commit complete.")

    logger.info(f"--- Processing Summary ---")
    logger.info(f"Cities Considered: {len(cities_to_process)}")
    logger.info(f"API Calls Attempted (Roughly): Wikidata ~{processed_count*2-error_count}, Wikipedia ~{processed_count-error_count}, LLM ~{processed_count-skipped_llm_count-error_count}") # Very rough estimate
    logger.info(f"Cities Updated in DB: {updated_count}")
    logger.info(f"Cities Where LLM Skipped: {skipped_llm_count}")
    logger.info(f"Cities with Errors: {error_count}")
    logger.info("--- Enrichment Process Finished ---")


# --- Script Entry Point ---
if __name__ == "__main__":
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
                  # Allow running without args

    try:
        asyncio.run(enrich_data(max_cities=max_cities_arg, update_all=update_all_arg))
    except KeyboardInterrupt:
        logger.info("Script interrupted by user.")
    except Exception as e:
         logger.critical(f"Script failed with critical error: {e}", exc_info=True)