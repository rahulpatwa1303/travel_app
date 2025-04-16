import psycopg2
import psycopg2.extras # For execute_batch, Json adapter
import json
import requests
import urllib.parse
import logging
import os
import time
from dotenv import load_dotenv

# --- Configuration ---
load_dotenv() # Load environment variables from .env file

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
# For more detailed logs during debugging:
# logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')


# --- Database Credentials ---
DB_NAME = os.getenv("PG_DBNAME")
DB_USER = os.getenv("PG_USER")
DB_PASSWORD = os.getenv("PG_PASSWORD")
DB_HOST = os.getenv("PG_HOST", "localhost")
DB_PORT = os.getenv("PG_PORT", "5432")

# --- Image Fetching Configuration ---
DEFAULT_STOCK_IMAGE_PATH = "/path/to/your/static/images/default_poi.jpg" # CHANGE THIS
FETCH_BATCH_SIZE = 500
UPDATE_BATCH_SIZE = 100
API_DELAY = 0.5
API_USER_AGENT = 'MyPOIUpdateScript/1.0 (contact@example.com)' # CHANGE THIS


# --- Wikimedia API Helper Functions (Keep these as they are) ---
def get_filename_from_wikidata(wikidata_id):
    # ... (function code from previous response) ...
    if not wikidata_id: return None
    try:
        endpoint_url = "https://www.wikidata.org/w/api.php"
        params = {
            "action": "wbgetclaims", "format": "json",
            "entity": wikidata_id, "property": "P18"
        }
        headers = {'User-Agent': API_USER_AGENT}
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()
        claims = data.get("claims", {}).get("P18", [])
        if claims:
            filename = claims[0].get("mainsnak", {}).get("datavalue", {}).get("value")
            if filename:
                return filename.replace(" ", "_")
    except requests.exceptions.RequestException as e:
        logging.warning(f"Wikidata API request failed for {wikidata_id}: {e}")
    except Exception as e:
        logging.error(f"Error processing Wikidata for {wikidata_id}: {e}", exc_info=False)
    return None

def search_wikimedia_commons_for_filename(query):
    # ... (function code from previous response) ...
    if not query: return None
    try:
        endpoint_url = "https://commons.wikimedia.org/w/api.php"
        params = {
            "action": "query", "format": "json", "list": "search",
            "srsearch": query, "srnamespace": 6, "srlimit": 1
        }
        headers = {'User-Agent': API_USER_AGENT}
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()
        search_results = data.get("query", {}).get("search", [])
        if search_results:
            title = search_results[0].get("title")
            if title and title.startswith("File:"):
                return title.split(":", 1)[1].replace(" ", "_")
    except requests.exceptions.RequestException as e:
        logging.warning(f"Wikimedia Commons search failed for '{query}': {e}")
    except Exception as e:
        logging.error(f"Error processing Wikimedia search for '{query}': {e}", exc_info=False)
    return None

def get_wikimedia_image_direct_url(filename):
    # ... (function code from previous response) ...
    if not filename: return None
    try:
        # Ensure filename doesn't accidentally start with File:
        clean_filename = filename
        if filename.lower().startswith("file:"):
            clean_filename = filename.split(":", 1)[1]

        endpoint_url = "https://commons.wikimedia.org/w/api.php"
        params = {
            "action": "query", "format": "json",
            "titles": f"File:{clean_filename}", # Need the File: prefix here
            "prop": "imageinfo", "iiprop": "url"
        }
        headers = {'User-Agent': API_USER_AGENT}
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()
        pages = data.get("query", {}).get("pages", {})
        for page_id in pages:
            # Handle missing pages or pages without imageinfo gracefully
            page_data = pages.get(page_id, {})
            if page_id != "-1" and "imageinfo" in page_data:
                image_info = page_data.get("imageinfo", [])
                if image_info:
                    url = image_info[0].get("url")
                    if url:
                         return url
        # If loop completes or page structure is unexpected, log and return None
        logging.warning(f"Could not find direct URL info for filename: {clean_filename}. API Response: {data}")
        return None
    except requests.exceptions.RequestException as e:
        logging.warning(f"Wikimedia imageinfo request failed for '{filename}': {e}")
    except Exception as e:
        logging.error(f"Error processing imageinfo for '{filename}': {e}", exc_info=False)
    return None


def find_image_url_for_poi(poi_name, tags_dict):
    # ... (function code from previous response, including API_DELAY) ...
    filename = None
    image_url = None

    # 1. Check existing 'image' tag (might be URL or filename)
    if tags_dict and 'image' in tags_dict:
        image_tag_value = tags_dict.get('image')
        if isinstance(image_tag_value, str):
            if image_tag_value.startswith("https://commons.wikimedia.org/wiki/File:"):
                try:
                    filename = urllib.parse.unquote(image_tag_value.split(":")[-1])
                    logging.debug(f"Found potential filename from 'image' tag: {filename}")
                except Exception: pass # Ignore parsing errors
            elif image_tag_value.startswith("http"):
                 image_url = image_tag_value
                 logging.debug(f"Found potential direct URL in 'image' tag: {image_url}")
                 # If we have a direct URL, we can probably return early unless we want to validate it?
                 # For now, let's assume it's valid if present.
                 return image_url # Return early
            elif ":" not in image_tag_value: # Basic check it might be a filename
                filename = image_tag_value.replace(" ", "_")
                logging.debug(f"Found potential filename directly in 'image' tag: {filename}")

    # 2. Check 'wikidata' tag if no filename/URL yet
    if not filename and not image_url and tags_dict and 'wikidata' in tags_dict:
        wikidata_id = tags_dict.get('wikidata')
        logging.debug(f"Checking Wikidata ({wikidata_id})...")
        time.sleep(API_DELAY) # Delay before API call
        filename = get_filename_from_wikidata(wikidata_id)
        if filename:
             logging.debug(f"Found filename via Wikidata: {filename}")

    # 3. Fallback: Search Wikimedia Commons if still no filename/URL
    if not filename and not image_url:
        search_term = poi_name
        if tags_dict and 'addr:city' in tags_dict:
            search_term += f" {tags_dict['addr:city']}"
        logging.debug(f"Searching Wikimedia Commons for '{search_term}'...")
        time.sleep(API_DELAY) # Delay before API call
        filename = search_wikimedia_commons_for_filename(search_term)
        if filename:
             logging.debug(f"Found filename via Wikimedia search: {filename}")

    # 4. If we have a filename, get the direct URL
    if filename and not image_url:
        logging.debug(f"Attempting to get direct URL for filename: {filename}")
        time.sleep(API_DELAY) # Delay before API call
        image_url = get_wikimedia_image_direct_url(filename)
        if image_url:
            logging.debug(f"Success! Direct URL: {image_url}")
        else:
             # Fallback to page URL only if the original tag contained it
             if tags_dict and 'image' in tags_dict and isinstance(tags_dict.get('image'), str) and tags_dict['image'].startswith("https://commons.wikimedia.org/wiki/File:"):
                 page_url_filename_part = urllib.parse.unquote(tags_dict['image'].split(":")[-1])
                 # Check if the filename we failed to get a direct URL for matches the one from the tag
                 if filename.replace("_", " ") == page_url_filename_part.replace("_", " "):
                      image_url = tags_dict['image'] # Fallback to page URL
                      logging.debug(f"Failed to get direct URL, falling back to page URL from tag: {image_url}")

    # 5. Return found URL or None
    return image_url


# --- Database Update Functions ---

def get_db_connection():
    # ... (function code from previous response) ...
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD,
            host=DB_HOST, port=DB_PORT
        )
        logging.info("Database connection established.")
        return conn
    except psycopg2.OperationalError as e:
        logging.error(f"Database connection failed: {e}")
        raise

def update_images_in_db(conn):
    """Fetches POIs and updates their tags with image URLs, one table fully at a time."""
    tables_to_update = ['landmarks', 'natural_wonders', 'restaurants_food']
    total_updated_count = 0
    total_processed_count = 0

    update_sql = """
        UPDATE {} SET tags = jsonb_set(COALESCE(tags, '{{}}'::jsonb), %s, %s, true) WHERE id = %s;
    """
    image_url_path = '{image_url}'

    # --- Iterate through each table SEQUENTIALLY ---
    for table in tables_to_update:
        logging.info(f"--- Starting processing for table: {table} ---")
        table_updated_count = 0
        table_processed_count = 0
        updates_to_batch = []
        cursor_name = f'fetch_{table}_cursor' # Unique cursor name per table

        try:
            # Use a server-side cursor for this specific table
            with conn.cursor(name=cursor_name) as cur:
                cur.itersize = FETCH_BATCH_SIZE
                logging.debug(f"Executing query to find records needing update in {table}...")
                cur.execute(f"""
                    SELECT id, name, tags
                    FROM {table}
                    WHERE tags IS NULL OR NOT (tags ? 'image_url');
                """)

                # --- Process ALL batches for the CURRENT table ---
                while True:
                    logging.debug(f"Attempting to fetch next batch for {table}...")
                    records = cur.fetchmany(FETCH_BATCH_SIZE)
                    logging.debug(f"Fetched {len(records)} records.")

                    if not records:
                        logging.debug(f"No more records found for {table}. Exiting inner loop.")
                        break # Exit the inner while loop when no more records for THIS table

                    logging.info(f"Processing batch of {len(records)} records from {table}...")

                    # --- Process each record in the current batch ---
                    for record_id, poi_name, tags_json in records:
                        table_processed_count += 1
                        total_processed_count += 1

                        # --- Inner Try-Except for individual record processing ---
                        # This allows skipping a single problematic record without stopping the batch/table
                        try:
                            tags_dict = tags_json if tags_json is not None else {}

                            # Check if image_url somehow exists (redundant with query, but safe)
                            if tags_dict.get('image_url'):
                                logging.debug(f"Skipping {table} ID {record_id}, already has image_url.")
                                continue

                            logging.debug(f"Processing {table} ID {record_id}: '{poi_name[:50]}...'")

                            # Find the image URL (includes API calls and delays)
                            found_url = find_image_url_for_poi(poi_name, tags_dict)
                            url_to_insert = found_url if found_url else DEFAULT_STOCK_IMAGE_PATH

                            # Prepare data for batch update
                            update_data = (image_url_path, psycopg2.extras.Json(url_to_insert), record_id)
                            updates_to_batch.append(update_data)

                        except Exception as record_error:
                             # Log error for the specific record, but continue with the batch
                            logging.error(f"Error processing record {table} ID {record_id} ('{poi_name}'): {record_error}", exc_info=False)
                            continue # Move to the next record in the batch
                        # --- End of Inner Try-Except ---


                    # --- Execute batch update if size reached ---
                    if len(updates_to_batch) >= UPDATE_BATCH_SIZE:
                        try:
                            logging.info(f"Executing batch update for {len(updates_to_batch)} records in {table}...")
                            with conn.cursor() as update_cur:
                                psycopg2.extras.execute_batch(update_cur, update_sql.format(table), updates_to_batch)
                            conn.commit() # Commit after successful batch
                            logging.info(f"Committed batch for {table}.")
                            table_updated_count += len(updates_to_batch)
                            total_updated_count += len(updates_to_batch)
                            updates_to_batch = [] # Reset batch
                        except (Exception, psycopg2.Error) as batch_commit_error:
                            logging.error(f"CRITICAL: Failed to execute/commit batch update for {table}: {batch_commit_error}", exc_info=True)
                            logging.warning("Rolling back current transaction...")
                            conn.rollback()
                            # Decide how to handle: Stop entirely? Skip rest of table?
                            # For safety, let's re-raise to trigger the outer exception handler and stop
                            raise batch_commit_error # Propagate the error

                # --- End of while True loop (finished fetching all batches for the table) ---

            # --- Process any remaining updates in the final batch for THIS table ---
            if updates_to_batch:
                try:
                    logging.info(f"Executing final batch update for {len(updates_to_batch)} records in {table}...")
                    with conn.cursor() as update_cur:
                         psycopg2.extras.execute_batch(update_cur, update_sql.format(table), updates_to_batch)
                    conn.commit() # Commit the final batch
                    logging.info(f"Committed final batch for {table}.")
                    table_updated_count += len(updates_to_batch)
                    total_updated_count += len(updates_to_batch)
                except (Exception, psycopg2.Error) as final_batch_error:
                    logging.error(f"CRITICAL: Failed to execute/commit final batch for {table}: {final_batch_error}", exc_info=True)
                    logging.warning("Rolling back current transaction...")
                    conn.rollback()
                    # Re-raise to trigger outer handler and stop
                    raise final_batch_error # Propagate the error


            logging.info(f"--- Finished processing table {table}. Processed: {table_processed_count}, Updated: {table_updated_count} ---")

        # --- Outer Try-Except for the ENTIRE table processing ---
        # Catches critical errors propagated from inner blocks or cursor issues
        except (Exception, KeyboardInterrupt, psycopg2.Error) as table_error:
            logging.error(f"A critical error occurred processing table {table}: {table_error}", exc_info=True)
            logging.warning("Rolling back any pending transaction for the current table...")
            try:
                # Ensure rollback happens even if connection is wonky
                 if not conn.closed: conn.rollback()
            except Exception as rb_error:
                logging.error(f"Rollback attempt failed: {rb_error}")

            logging.warning(f"Stopping further processing due to error in table {table}.")
            # --- IMPORTANT: Break the outer loop - stop processing subsequent tables ---
            break
        # --- End of Outer Try-Except ---

    # --- End of the main loop iterating through tables ---

    logging.info(f"--- Image Update Script Finished ---")
    logging.info(f"Total records processed across all tables attempted: {total_processed_count}")
    logging.info(f"Total records updated across all tables attempted: {total_updated_count}")


# --- Main Execution ---
if __name__ == "__main__":
    conn = None
    start_run_time = time.time()
    try:
        conn = get_db_connection()
        update_images_in_db(conn)
    except Exception as e:
        # Catch any unexpected errors during connection or top-level issues
        logging.critical(f"Script failed unexpectedly at the top level: {e}", exc_info=True)
    finally:
        if conn and not conn.closed:
            conn.close()
            logging.info("Database connection closed.")
        elif conn and conn.closed:
             logging.info("Database connection was already closed.")

        end_run_time = time.time()
        logging.info(f"Total script execution time: {end_run_time - start_run_time:.2f} seconds")