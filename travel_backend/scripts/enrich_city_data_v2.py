# scripts/enrich_city_data_final.py
# Fetches Wikidata, Wikipedia Intro, generates structured data via Ollama LLM,
# and updates DB row-by-row.

import asyncio
import httpx
import logging
import os
import sys
import json # For parsing LLM JSON output
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict, Any, Tuple

# --- OpenAI library ---
try:
    from openai import AsyncOpenAI, OpenAIError
except ImportError:
    print("Error: 'openai' library not found. Please install it: pip install openai")
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
except ImportError as e:
    print(f"Error importing app components: {e}")
    sys.exit(1)

# --- Logging Setup ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("enrich_city_data")

# --- Configuration ---
WIKIDATA_API_URL = "https://www.wikidata.org/w/api.php"
WIKIPEDIA_API_URL = "https://en.wikipedia.org/w/api.php"
HTTP_HEADERS = { # !! UPDATE USER-AGENT !!
    "User-Agent": "YourTravelAppName/1.0 (contact@youremail.com; script: enrich_city_data)"
}
WIKIDATA_API_DELAY = 1.0
WIKIPEDIA_API_DELAY = 0.3
WIKIDATA_BATCH_SIZE = 40

# Ollama / LLM Config
# !! CHOOSE/UPDATE OLLAMA_BASE_URL !!
OLLAMA_BASE_URL = "http://192.168.29.200:8080/v1"
OLLAMA_API_KEY = "ollama"
LLM_MODEL = "mistral:latest"
LLM_TIMEOUT = 380.0 # Increased timeout for potentially slower local generation
LLM_MAX_RETRIES = 3
LLM_RETRY_DELAY = 5

# --- Initialize Clients ---
try:
    client_llm = AsyncOpenAI(
        base_url=OLLAMA_BASE_URL, api_key=OLLAMA_API_KEY,
        timeout=LLM_TIMEOUT, max_retries=0
    )
    http_client = httpx.AsyncClient(headers=HTTP_HEADERS, timeout=30.0, follow_redirects=True)
except Exception as e:
    logger.error(f"Failed to initialize API clients: {e}")
    sys.exit(1)


# ==================================
# --- Wikidata Helper Functions ---
# (search_wikidata_for_city, get_wikidata_entity_details_batch,
#  extract_property_value, extract_description, extract_label)
# --- Keep these functions exactly as in the previous 'Complete Script' version ---
async def search_wikidata_for_city(city_name: str, country_name: str, client: httpx.AsyncClient) -> Optional[str]:
    search_params={"action": "wbsearchentities","format": "json","language": "en","type": "item","limit": 5,"search": city_name}
    logger.debug(f"WD Search: '{city_name}, {country_name}'")
    try:
        response=await client.get(WIKIDATA_API_URL, params=search_params, timeout=20.0)
        response.raise_for_status()
        data=response.json()
        results=data.get("search", [])
        if not results: return None
        for result in results:
            qid=result.get("id"); desc=result.get("description", "").lower()
            if country_name.lower() in desc: logger.debug(f"Found QID: {qid} ('{desc}')"); return qid
        logger.debug(f"No WD result matched country '{country_name}'."); return None
    except Exception as e: logger.error(f"Error WD search for '{city_name}': {e}"); return None

async def get_wikidata_entity_details_batch(qids: List[str], client: httpx.AsyncClient) -> Optional[Dict[str, Any]]:
    """Fetches details for multiple Wikidata entities (QIDs) in a batch."""
    if not qids:
        logger.warning("get_wikidata_entity_details_batch called with empty QID list.")
        return None

    # --- !!! ADD OR UNCOMMENT THIS LINE !!! ---
    qids_str = "|".join(qids)
    # --- !!! ---

    params = {
        "action": "wbgetentities", "ids": qids_str, "format": "json",
        "props": "claims|labels|descriptions", "languages": "en",
    }
    logger.debug(f"Fetching WD entity details batch for: {len(qids)} QIDs starting with {qids[0]}")
    try:
        # Add delay before actual call? Maybe not needed here if called after other delays
        # await asyncio.sleep(WIKIDATA_API_DELAY / 2) # Optional smaller delay before batch fetch
        response = await client.get(WIKIDATA_API_URL, params=params, timeout=30.0)
        response.raise_for_status()
        data = response.json()
        entities = data.get("entities")
        if not entities:
            logger.warning(f"WD batch fetch for {qids_str} returned no entities.")
            return None
        return entities
    except httpx.TimeoutException:
         logger.error(f"Timeout fetching WD entity batch starting {qids[0]}"); return None
    except httpx.RequestError as e:
         logger.error(f"HTTP error fetching WD entity batch starting {qids[0]}: {e}"); return None
    except Exception as e:
         logger.error(f"Error processing WD entity batch starting {qids[0]}: {e}"); return None
    
def extract_property_value(entity_data: Dict[str, Any], property_id: str) -> Optional[Any]:
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
    descriptions=entity_data.get("descriptions", {}); en_desc=descriptions.get("en"); return en_desc.get("value") if en_desc else None
def extract_label(entity_data: Dict[str, Any]) -> Optional[str]:
    labels=entity_data.get("labels", {}); en_label=labels.get("en"); return en_label.get("value") if en_label else None
# ====================================

# ====================================
# --- Wikipedia Helper Functions ---
# (get_wikipedia_intro)
# --- Keep this function exactly as in the previous 'Complete Script' version ---
async def get_wikipedia_intro(city_name: str, country_name: str, client_http: httpx.AsyncClient) -> Optional[str]:
    search_term = f"{city_name}"; logger.debug(f"Fetching WP intro for: {search_term}")
    params={"action": "query","format": "json","titles": search_term,"prop": "extracts","exintro": True,"explaintext": True,"redirects": 1,"origin": "*"}
    try:
        response=await client_http.get(WIKIPEDIA_API_URL, params=params, timeout=15.0)
        response.raise_for_status(); data=response.json(); pages=data.get("query", {}).get("pages", {})
        if pages:
            page_id=list(pages.keys())[0]
            if page_id != "-1":
                extract=pages[page_id].get("extract");
                if extract and len(extract) > 10: logger.debug(f"Found WP intro for {city_name} (len {len(extract)})."); return extract.strip()
        logger.debug(f"WP intro not found for {city_name}."); return None
    except Exception as e: logger.error(f"Error fetching WP intro for {city_name}: {e}"); return None
# ====================================

# ================================
# --- LLM Helper Functions ---
# ================================
async def generate_structured_city_info(
    city_name: str, country_name: str,
    wikidata_desc: Optional[str], wikipedia_intro: Optional[str]
) -> Optional[Dict[str, Any]]:
    """Generates structured city info (desc, time, famous, budget) using the LLM."""
    logger.debug(f"Attempting LLM structured generation for {city_name}...")

    context = f"City Name: {city_name}\nCountry: {country_name}\n"
    if wikidata_desc: context += f"Wikidata Description: {wikidata_desc}\n"
    if wikipedia_intro:
        intro_snippet = (wikipedia_intro[:800] + '...') if len(wikipedia_intro) > 800 else wikipedia_intro
        context += f"Wikipedia Intro Snippet: {intro_snippet}\n"

    if not wikidata_desc and not wikipedia_intro:
        logger.warning(f"Skipping LLM for {city_name}: Insufficient input context.")
        return None

    # --- !! USE THE NEW PROMPT !! ---
    prompt = f"""
You are a helpful travel information assistant outputting structured data.
Based only on the information provided below about the city and your general knowledge of world cities, generate the required travel details.
Instructions:
Analyze the input.
Generate JSON containing: "description", "best_time_to_travel", "famous_for", "budget_scale", "budget_summary".
Adhere strictly to the field descriptions and constraints below.
Output ONLY the raw JSON object. No introductory text, no explanations, no markdown formatting.
**Input Information:**
---
{context.strip()}
---
**Output JSON Format:**


```json
{{
  "description": "A concise and engaging travel description (1-2 paragraphs, max 150 words) highlighting what makes the city interesting based on input/general knowledge.",
  "best_time_to_travel": "A brief text description of the best times to visit. Structure it clearly, mentioning key seasons/months and the primary reason (e.g., weather, events, scenery). Example: 'Spring (Apr-May): Pleasant weather, cherry blossoms. Autumn (Sep-Oct): Mild temperatures, fall colors. Summer (Jul-Aug): Warm but potentially crowded. Winter (Dec-Feb): Cold, festive atmosphere.'",
  "famous_for": [
    "JSON list of 3-5 key landmarks, attractions, or defining features (e.g., 'Eiffel Tower', 'Louvre Museum', 'French Cuisine')."
  ],
  "budget_scale": "Estimated budget scale from 1 (very cheap) to 5 (very expensive) for a typical tourist. Provide ONLY the integer number (1, 2, 3, 4, or 5).",
  "budget_summary": "A very short phrase corresponding to the budget_scale (e.g., 'Very Affordable', 'Mid-Range', 'Pricey'). Choose ONE appropriate phrase based on the 1-5 scale."
}}"""
# Note: Using {{ and }} in the f-string to escape the JSON braces for the final output
    extracted_json = None
    for attempt in range(LLM_MAX_RETRIES + 1):
        try:
            logger.debug(f"LLM API Call for {city_name} (Attempt {attempt + 1})")
            response = await client_llm.chat.completions.create(
                model=LLM_MODEL,
                messages=[
                    {"role": "system", "content": "You are an assistant that only outputs valid JSON."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=500,
                temperature=0.5,
                # Use response_format if your Ollama/model version supports it reliably
                # response_format={"type": "json_object"},
                timeout=LLM_TIMEOUT
            )
            raw_llm_output = response.choices[0].message.content.strip()
            logger.debug(f"LLM Raw Response for {city_name}: {raw_llm_output[:200]}...")

            # Parse and Validate JSON
            try:
                json_start = raw_llm_output.find('{')
                json_end = raw_llm_output.rfind('}') + 1
                if json_start != -1 and json_end != -1:
                    json_string = raw_llm_output[json_start:json_end]
                    parsed_json = json.loads(json_string)
                    required_keys = {"description", "best_time_to_travel", "famous_for", "budget_scale", "budget_summary"}
                    if not required_keys.issubset(parsed_json.keys()):
                        raise ValueError(f"LLM output missing required keys. Found: {list(parsed_json.keys())}")

                    # Validate budget_scale (1-5)
                    raw_scale = parsed_json.get("budget_scale")
                    scale_num = int(raw_scale) # Will raise ValueError if not int
                    if not (1 <= scale_num <= 5):
                       logger.warning(f"LLM budget_scale {scale_num} out of range (1-5) for {city_name}. Clamping.")
                       parsed_json["budget_scale"] = max(1, min(5, scale_num)) # Clamp value
                    else:
                       parsed_json["budget_scale"] = scale_num # Store the valid int

                    logger.info(f"LLM successfully generated and parsed structured JSON for {city_name}.")
                    return parsed_json # Success!

                else: raise ValueError("JSON block markers not found")

            except (json.JSONDecodeError, ValueError, TypeError) as json_err:
                logger.error(f"Failed to parse/validate LLM JSON response for {city_name}: {json_err}. Output: {raw_llm_output}")
                raise OpenAIError("Invalid JSON received") # Re-raise to trigger retry

        except Exception as e:
            logger.error(f"Error calling LLM API for {city_name} (Attempt {attempt+1}/{LLM_MAX_RETRIES+1}): {e}")
            if attempt < LLM_MAX_RETRIES:
                logger.info(f"Retrying LLM call after {LLM_RETRY_DELAY}s...")
                await asyncio.sleep(LLM_RETRY_DELAY)
            else:
                logger.error(f"LLM call failed after {LLM_MAX_RETRIES+1} attempts for {city_name}.")
                return None # Failed after retries
    return None # Failed all attempts


# ==================================
# --- Main Processing Function ---
# ==================================
async def enrich_data(max_cities: Optional[int] = None):
    """Fetches details for cities and updates the database row-by-row, skipping already completed rows."""
    start_time = datetime.now()
    processed_count = 0
    skipped_fully_populated = 0 # Counter for skipped cities
    updated_db_count = 0
    llm_success_count = 0
    qid_found_count = 0
    error_count = 0
    cities_to_process: List[models.City] = []

    logger.info("Starting city enrichment process (Row-by-Row Update, Skip Completed)...")
    if max_cities: logger.info(f"Maximum cities to process: {max_cities}")

    # --- Get Cities from DB ---
    logger.info("Connecting to database and fetching cities...")
    async with AsyncSessionLocal() as db_fetch:
        stmt = select(models.City).options(joinedload(models.City.country)).order_by(models.City.id)
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
        country_name = city.country.name if city.country else "Unknown Country"
        logger.info(f"--- Processing {processed_count}/{total_cities_to_process}: {city_name} (ID: {city.id}) ---")

        # --- !!! CHECK IF ALREADY FULLY POPULATED !!! ---
        # Check if all target fields generated by LLM (+ Wikidata ID) are non-null
        if (
            city.wikidata_id is not None and # Ensure we have the QID
            city.description is not None and city.description.strip() != "" and
            city.best_time_to_travel is not None and city.best_time_to_travel.strip() != "" and
            city.famous_for is not None and city.famous_for.strip() != "" and
            city.budget_scale is not None and # Check the number
            city.budget_summary is not None and city.budget_summary.strip() != ""
        ):
            logger.info(f"Skipping city {city.id} ({city_name}): All target fields already populated.")
            skipped_fully_populated += 1
            continue # Move to the next city
        # --- !!! END OF CHECK !!! ---


        update_payload: Dict[str, Any] = {}
        wikidata_description: Optional[str] = None
        wiki_intro: Optional[str] = None
        current_wikidata_id: Optional[str] = city.wikidata_id

        try:
            # --- 1. Get Wikidata QID (if missing) ---
            # (This check is now slightly redundant due to the skip above, but harmless)
            if not current_wikidata_id:
                logger.info("Searching Wikidata ID...")
                qid = await search_wikidata_for_city(city_name, country_name, http_client)
                await asyncio.sleep(WIKIDATA_API_DELAY)
                if qid:
                    update_payload["wikidata_id"] = qid
                    current_wikidata_id = qid
                    qid_found_count += 1
                else:
                    logger.warning("Could not find Wikidata ID. Some details might be missing.")
                    # Continue processing, LLM might still work with city/country name

            # --- 2. Get Wikidata Details (if QID exists) ---
            if current_wikidata_id:
                 # ... (Fetch WD details, extract population, timezone - No change here) ...
                 logger.info(f"Fetching Wikidata details for {current_wikidata_id}...")
                 entity_data_batch = await get_wikidata_entity_details_batch([current_wikidata_id], http_client)
                 await asyncio.sleep(WIKIDATA_API_DELAY)
                 if entity_data_batch and current_wikidata_id in entity_data_batch:
                     wd_details = entity_data_batch[current_wikidata_id]
                     wikidata_description = extract_description(wd_details) # Get WD desc for LLM input
                     pop_str = extract_property_value(wd_details, "P1082")
                     if pop_str: 
                        try: update_payload["population"] = int(float(pop_str)) # noqa E722
                        except ValueError: logger.warning(f"Invalid WD population value: {pop_str}")
                     tz_qid = extract_property_value(wd_details, "P421")
                     if tz_qid: update_payload["timezone"] = tz_qid # Storing QID
                 else: logger.warning(f"Failed to get entity data for {current_wikidata_id}")

            # --- 3. Fetch Wikipedia Intro ---
            logger.info("Fetching Wikipedia intro...")
            wiki_intro = await get_wikipedia_intro(city_name, country_name, http_client)
            await asyncio.sleep(WIKIPEDIA_API_DELAY)

            # --- 4. Generate Structured Info via LLM ---
            # LLM is always called now if the initial check passed
            logger.info("Attempting LLM structured generation...")
            llm_generated_data = await generate_structured_city_info(
                city_name=city_name, country_name=country_name,
                wikidata_desc=wikidata_description, # Use description from WD fetch
                wikipedia_intro=wiki_intro
            )
            # No need for sleep here, handled in finally block

            # --- 5. Prepare DB Update Payload from LLM results ---
            if llm_generated_data:
                llm_success_count += 1
                logger.info("LLM generation successful. Merging results into update payload.")
                # Merge LLM results, potentially overwriting WD values if present in both
                if "description" in llm_generated_data: update_payload["description"] = llm_generated_data["description"]
                if "best_time_to_travel" in llm_generated_data: update_payload["best_time_to_travel"] = llm_generated_data["best_time_to_travel"]
                famous_list = llm_generated_data.get("famous_for");
                if isinstance(famous_list, list): update_payload["famous_for"] = ", ".join(filter(None, map(str, famous_list)))
                elif famous_list: update_payload["famous_for"] = str(famous_list) # Handle non-list case
                if "budget_scale" in llm_generated_data: update_payload["budget_scale"] = llm_generated_data["budget_scale"]
                if "budget_summary" in llm_generated_data: update_payload["budget_summary"] = llm_generated_data["budget_summary"]
            else:
                logger.error(f"LLM generation failed for {city_name}. Update payload will only contain Wikidata info.")

            # --- 6. Add timestamp and Update DB for THIS City (if any changes) ---
            # Check if update_payload actually contains *new* info compared to original city object
            # This avoids unnecessary DB updates if only QID was found but LLM failed etc.
            needs_db_update = False
            for key, value in update_payload.items():
                 if getattr(city, key, None) != value:
                      needs_db_update = True
                      break

            if needs_db_update:
                update_payload["details_last_updated"] = datetime.now(timezone.utc)
                try:
                    async with AsyncSessionLocal() as db_update:
                        logger.info(f"Updating DB for city ID {city.id} with keys: {list(update_payload.keys())}")
                        stmt_update = update(models.City).where(models.City.id == city.id).values(**update_payload)
                        await db_update.execute(stmt_update)
                        await db_update.commit()
                        updated_db_count += 1
                except SQLAlchemyError as db_err:
                     logger.error(f"Database update failed for city {city.id}: {db_err}", exc_info=True)
                     # await db_update.rollback() # Handled by context manager
                     error_count += 1
                except Exception as e_upd:
                     logger.error(f"Unexpected error during DB update for city {city.id}: {e_upd}", exc_info=True)
                     error_count += 1
            else:
                logger.info(f"No actual data changes detected to update DB for city ID {city.id}")

        except Exception as e:
             logger.error(f"!! Unhandled error processing city {city.id} ({city_name}): {e}", exc_info=True)
             error_count += 1
        finally:
            # Delay before starting the next city's processing
            await asyncio.sleep(0.2) # Small delay between cities overall

    # --- Final Summary ---
    await http_client.aclose()
    end_time = datetime.now()
    duration = end_time - start_time
    logger.info(f"--- Enrichment Process Finished ---")
    logger.info(f"Duration: {duration}")
    logger.info(f"Total Cities Considered: {total_cities_to_process}")
    logger.info(f"Cities Processed in Loop: {processed_count}")
    logger.info(f"Cities Skipped (Already Populated): {skipped_fully_populated}") # Added skip count
    logger.info(f"New Wikidata IDs Found: {qid_found_count}")
    logger.info(f"LLM Generations Successful: {llm_success_count}")
    logger.info(f"Cities Updated in DB: {updated_db_count}")
    logger.info(f"Cities with Errors: {error_count}")


# --- Script Entry Point ---
if __name__ == "__main__":
    # ... (Argument parsing - same as last version) ...
    max_cities_arg = None
    if len(sys.argv) > 1:
        try:
            max_cities_arg = int(sys.argv[1])
            logger.info(f"Running for a maximum of {max_cities_arg} cities.")
        except ValueError:
            print(f"Usage: python {sys.argv[0]} [max_cities]")
    try:
        asyncio.run(enrich_data(max_cities=max_cities_arg))
    except KeyboardInterrupt: logger.info("Script interrupted by user.")
    except Exception as e: logger.critical(f"Script failed: {e}", exc_info=True)