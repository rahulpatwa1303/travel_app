# utils/image_fetcher.py
import httpx
import asyncio
import urllib.parse
import logging
import time # For potential delays
from typing import Optional, List, Dict, Any

logger = logging.getLogger(__name__)

# --- Configuration ---
WIKIMEDIA_COMMONS_API_URL = "https://commons.wikimedia.org/w/api.php"
WIKIDATA_API_URL = "https://www.wikidata.org/w/api.php"
API_USER_AGENT = 'YourFastAPIApp/1.0 (YourContactURL or email)' # PLEASE UPDATE
API_TIMEOUT = 15 # seconds
# Optional delay between consecutive API calls (seconds) to be polite
API_DELAY = 0.1 # Be cautious with very low delays if making many requests

# --- Stock Image Path ---
# Define this in your config/settings
DEFAULT_STOCK_IMAGE_PATH = "/static/images/default_poi.jpg" # Example

async def _make_api_request(client: httpx.AsyncClient, url: str, params: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Helper to make API requests with error handling."""
    headers = {'User-Agent': API_USER_AGENT}
    try:
        # Add a small delay before each request
        await asyncio.sleep(API_DELAY)
        response = await client.get(url, params=params, headers=headers, timeout=API_TIMEOUT)
        response.raise_for_status() # Raise exception for bad status codes
        return response.json()
    except httpx.RequestError as e:
        logger.warning(f"HTTP Request Error to {e.request.url}: {e}")
    except httpx.HTTPStatusError as e:
        logger.warning(f"HTTP Status Error {e.response.status_code} for {e.request.url}: {e.response.text[:200]}")
    except Exception as e:
        logger.error(f"Unexpected error during API request to {url}: {e}", exc_info=True)
    return None

async def get_filename_from_wikidata(client: httpx.AsyncClient, wikidata_id: str) -> Optional[str]:
    """Fetches the main image filename (P18) from a Wikidata item."""
    if not wikidata_id: return None
    logger.debug(f"Fetching filename from Wikidata ID: {wikidata_id}")
    params = {
        "action": "wbgetclaims", "format": "json",
        "entity": wikidata_id, "property": "P18", "utf8": 1
    }
    data = await _make_api_request(client, WIKIDATA_API_URL, params)
    if data:
        try:
            claims = data.get("claims", {}).get("P18", [])
            if claims:
                filename = claims[0].get("mainsnak", {}).get("datavalue", {}).get("value")
                if filename:
                    logger.debug(f"Found filename via Wikidata: {filename}")
                    return filename.replace(" ", "_")
        except Exception as e:
            logger.error(f"Error parsing Wikidata response for {wikidata_id}: {e} - Data: {data}")
    logger.debug(f"No P18 filename found for Wikidata ID: {wikidata_id}")
    return None

async def search_commons_for_filenames(client: httpx.AsyncClient, query: str) -> List[str]:
    """Searches Wikimedia Commons and returns a list of potential filenames."""
    if not query.strip(): return []
    logger.debug(f"Searching Wikimedia Commons for: \"{query}\"")
    params = {
        "action": "query", "format": "json", "list": "search",
        "srsearch": query, "srnamespace": 6, "srlimit": 3, "utf8": 1
    }
    data = await _make_api_request(client, WIKIMEDIA_COMMONS_API_URL, params)
    filenames = []
    if data:
        try:
            search_results = data.get("query", {}).get("search", [])
            for result in search_results:
                title = result.get("title")
                if title and title.startswith("File:"):
                    filenames.append(title.split(":", 1)[1].replace(" ", "_"))
        except Exception as e:
             logger.error(f"Error parsing Commons search response for '{query}': {e} - Data: {data}")

    logger.debug(f"Found {len(filenames)} potential filenames for query \"{query}\": {filenames}")
    return filenames

async def get_wikimedia_image_direct_url(client: httpx.AsyncClient, filename: str) -> Optional[str]:
    """Gets the direct image URL from Wikimedia Commons using the filename."""
    if not filename: return None
    logger.debug(f"Attempting to get direct URL for filename: {filename}")
    if filename.lower().startswith("file:"):
        filename = filename.split(":", 1)[1]

    params = {
        "action": "query", "format": "json", "titles": f"File:{filename}",
        "prop": "imageinfo", "iiprop": "url", "utf8": 1
    }
    data = await _make_api_request(client, WIKIMEDIA_COMMONS_API_URL, params)
    if data:
        try:
            pages = data.get("query", {}).get("pages", {})
            for page_id, page_info in pages.items():
                if page_id != "-1" and isinstance(page_info, dict):
                    image_info_list = page_info.get("imageinfo", [])
                    if image_info_list and isinstance(image_info_list[0], dict):
                        image_url = image_info_list[0].get("url")
                        if image_url:
                            logger.debug(f"Success! Found direct URL: {image_url}")
                            return image_url
                    else:
                         logger.debug(f"No imageinfo list found for {filename} in page {page_id}")
                    break # Process first valid page found
            logger.debug(f"No valid page entry or URL found in direct URL response for {filename}")
        except Exception as e:
            logger.error(f"Error parsing imageinfo response for {filename}: {e} - Data: {data}")

    logger.warning(f"Failed to get direct URL for filename: {filename}")
    return None

async def find_image_url_for_poi_api(
    client: httpx.AsyncClient,
    poi_name: str,
    tags: Optional[Dict[str, Any]]
) -> tuple[Optional[str], Optional[str]]:
    """
    Enhanced logic to find image URL, returning (url, source).
    Uses async client.
    """
    tags = tags or {}
    image_url: Optional[str] = None
    source: Optional[str] = None
    filenames_to_try: List[str] = []

    wikidata_id = tags.get('wikidata')
    city = tags.get('addr:city', '')
    alt_name = tags.get('alt_name', '')

    # 1. Try Wikidata
    if wikidata_id:
        wikidata_filename = await get_filename_from_wikidata(client, wikidata_id)
        if wikidata_filename:
            filenames_to_try.append(wikidata_filename)
            # Try getting URL immediately
            image_url = await get_wikimedia_image_direct_url(client, wikidata_filename)
            if image_url:
                logger.info(f"Image URL found via Wikidata for '{poi_name}'.")
                return image_url, "wikidata" # Success

    # 2. Search Commons (only if Wikidata didn't yield final URL)
    if not image_url:
        search_queries = []
        if city: search_queries.append(f'{poi_name} {city}')
        search_queries.append(poi_name)
        if alt_name and city: search_queries.append(f'{alt_name} {city}')
        if alt_name: search_queries.append(alt_name)

        found_filenames_from_search = set()
        for query in search_queries:
            results = await search_commons_for_filenames(client, query)
            if results:
                found_filenames_from_search.update(results)
            # Optional: break early if results found for a specific query?
            # if results: break

        # Add unique search results to the list, prioritize Wikidata filename if it exists
        existing_set = set(filenames_to_try)
        for fname in found_filenames_from_search:
             if fname not in existing_set:
                 filenames_to_try.append(fname)

    # 3. Try getting Direct URL for found filenames
    if not image_url and filenames_to_try:
        logger.debug(f"Trying {len(filenames_to_try)} filenames for '{poi_name}': {filenames_to_try}")
        for filename in filenames_to_try:
            image_url = await get_wikimedia_image_direct_url(client, filename)
            if image_url:
                logger.info(f"Image URL found via Commons Search for '{poi_name}' (filename: {filename}).")
                source = "commons_search"
                break # Stop on first success

    # 4. Final Result (or Stock/Not Found)
    if image_url:
        return image_url, source or "unknown" # Should have source if found here
    else:
        logger.warning(f"Failed to find any image URL for '{poi_name}'.")
        # Decide if you want to return stock image URL here or mark as 'not_found'
        # Option 1: Return stock
        # return DEFAULT_STOCK_IMAGE_PATH, "stock"
        # Option 2: Return None, indicating truly not found
        return None, "not_found"