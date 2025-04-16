# app/image_fetcher.py
import logging
import json
import asyncio
from typing import Optional, Dict, Any, Tuple
import aiohttp # For async HTTP requests
import asyncpg
from datetime import datetime, timedelta

from app.models import CATEGORY_MAP

logger = logging.getLogger(__name__)

# --- Wikimedia Commons API Interaction (Simplified) ---
COMMONS_API_URL = "https://commons.wikimedia.org/w/api.php"
# Be polite to Wikimedia APIs
WIKI_HEADERS = {
    'User-Agent': 'YourAppName/1.0 (your_contact_email@example.com or link to project)'
}
# How long to consider cache valid before re-fetching (e.g., 7 days)
CACHE_EXPIRY_DAYS = 7
DEFAULT_IMAGE_PLACEHOLDER = "_use_default_if_null_found"

async def _fetch_commons_image_url(session: aiohttp.ClientSession, search_term: str) -> Optional[str]:
    """
    Simplified fetch: Performs a search and tries to get the first image result.
    A robust implementation would handle categories, Wikidata IDs, etc.
    """
    params = {
        "action": "query",
        "format": "json",
        "list": "search",
        "srsearch": search_term,
        "srnamespace": "6",  # Search only in File namespace
        "srlimit": "1",      # Get only the first result
        "srprop": "",        # Don't need snippets etc.
    }
    try:
        async with session.get(COMMONS_API_URL, params=params, headers=WIKI_HEADERS, timeout=10) as response:
            response.raise_for_status()
            data = await response.json()
            search_results = data.get("query", {}).get("search", [])
            if search_results:
                first_result_title = search_results[0].get("title")
                if first_result_title:
                    # Need another query to get the actual image URL from the file title
                    return await _get_image_url_from_title(session, first_result_title)
            logger.debug(f"No image search results on Commons for: {search_term}")
            return None
    except asyncio.TimeoutError:
         logger.warning(f"Timeout fetching image search from Commons for: {search_term}")
         return None
    except aiohttp.ClientError as e:
        logger.error(f"HTTP Client error fetching image search from Commons for '{search_term}': {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error fetching image search from Commons for '{search_term}': {e}")
        return None

async def _get_image_url_from_title(session: aiohttp.ClientSession, file_title: str) -> Optional[str]:
    """Gets the direct image URL for a given Wikimedia Commons file title."""
    params = {
        "action": "query",
        "format": "json",
        "prop": "imageinfo",
        "titles": file_title,
        "iiprop": "url", # Request the direct URL
    }
    try:
        async with session.get(COMMONS_API_URL, params=params, headers=WIKI_HEADERS, timeout=10) as response:
            response.raise_for_status()
            data = await response.json()
            pages = data.get("query", {}).get("pages", {})
            if pages:
                # Page ID is unknown, so get the first page entry
                page_info = next(iter(pages.values()), None)
                if page_info and "imageinfo" in page_info:
                    image_url = page_info["imageinfo"][0].get("url")
                    logger.debug(f"Found Commons image URL for '{file_title}': {image_url}")
                    return image_url
            logger.debug(f"Could not extract image URL for Commons title: {file_title}")
            return None
    except asyncio.TimeoutError:
         logger.warning(f"Timeout fetching image URL from Commons for title: {file_title}")
         return None
    except aiohttp.ClientError as e:
        logger.error(f"HTTP Client error fetching image URL from Commons for '{file_title}': {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error fetching image URL from Commons for '{file_title}': {e}")
        return None

# --- Database Cache Interaction ---

async def get_cached_image(conn: asyncpg.Connection, place_table: str, place_id: int) -> Optional[Tuple[Optional[str], datetime]]:
    """Checks cache. Returns (image_url, last_fetched_at) or None."""
    query = """
        SELECT image_url, last_fetched_at FROM poi_images
        WHERE place_table = $1 AND place_id = $2;
    """
    try:
        record = await conn.fetchrow(query, place_table, place_id)
        if record:
            # Return URL (can be None if 'not_found' was cached) and fetch time
            return record['image_url'], record['last_fetched_at']
        return None
    except Exception as e:
        logger.error(f"Error fetching cached image for {place_table}:{place_id}: {e}")
        return None # Treat DB error as cache miss

async def cache_image_url(conn: asyncpg.Connection, place_table: str, place_id: int, image_url: Optional[str], source: str):
    """Inserts or updates the image cache entry."""
    query = """
        INSERT INTO poi_images (place_table, place_id, image_url, source, last_fetched_at)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (place_table, place_id) DO UPDATE SET
            image_url = EXCLUDED.image_url,
            source = EXCLUDED.source,
            last_fetched_at = NOW();
    """
    try:
        await conn.execute(query, place_table, place_id, image_url, source)
        logger.debug(f"Cached image result for {place_table}:{place_id} (Source: {source}, URL: {'Found' if image_url else 'Not Found'})")
    except Exception as e:
        logger.error(f"Error caching image for {place_table}:{place_id}: {e}")
        # Don't raise, failing to cache shouldn't break the main request

# --- Main Orchestrator Function ---

async def fetch_and_cache_image_for_place(
    session: aiohttp.ClientSession, # Pass the session for reuse
    conn: asyncpg.Connection,
    place_dict: Dict[str, Any] # Dict representing the place from DB
) -> Optional[str]:
    """
    Orchestrates checking cache, fetching from Commons if needed, caching result,
    and returning the image URL or the default placeholder.
    """
    if not place_dict or 'id' not in place_dict or 'category' not in place_dict:
        logger.warning("fetch_and_cache_image_for_place received invalid place_dict")
        return DEFAULT_IMAGE_PLACEHOLDER # Return default if input invalid

    place_id = place_dict['id']
    category_key = place_dict['category']
    # Determine table name from category
    category_info = CATEGORY_MAP.get(category_key)
    if not category_info:
        logger.warning(f"Cannot determine place_table for category '{place_dict['category']}' for place ID {place_id}")
        return DEFAULT_IMAGE_PLACEHOLDER
    place_table = category_info['table']

    # 1. Check Cache
    cached_result = await get_cached_image(conn, place_table, place_id)
    if cached_result:
        cached_url, fetched_at = cached_result
        cache_expiry_time = datetime.utcnow() - timedelta(days=CACHE_EXPIRY_DAYS)
        # Check if cache entry is recent enough (naive UTC comparison)
        if fetched_at and fetched_at.replace(tzinfo=None) > cache_expiry_time:
            logger.debug(f"Using recent cached image for {place_table}:{place_id}")
            # Return the cached URL, even if it was None (meaning 'not_found' previously)
            # Return placeholder ONLY if the cached value is explicitly None (meaning not found previously)
            return cached_url if cached_url is not None else DEFAULT_IMAGE_PLACEHOLDER
        else:
            logger.info(f"Cached image for {place_table}:{place_id} is stale or missing fetch date. Re-fetching.")

    # 2. Prepare Search Terms / Identifiers
    tags = place_dict.get('tags') or {}
    name = place_dict.get('name')
    wikidata_id = tags.get('wikidata')
    commons_tag = tags.get('wikimedia_commons')
    city = tags.get('addr:city')

    image_url: Optional[str] = None
    source: str = "not_found" # Default source if nothing works

    # --- Try different fetching strategies ---

    # Strategy A: Direct 'image' tag (less common for places, more for specific features)
    if not image_url:
        image_url = tags.get('image')
        if image_url:
            logger.info(f"Found image URL directly in 'image' tag for {place_table}:{place_id}")
            source = "osm_image_tag"

    # Strategy B: Parse 'wikimedia_commons' tag
    if not image_url and commons_tag:
        logger.debug(f"Attempting fetch via wikimedia_commons tag: {commons_tag}")
        if commons_tag.startswith("File:"):
            file_title = commons_tag
            image_url = await _get_image_url_from_title(session, file_title)
            if image_url: source = "commons_file_tag"
        elif commons_tag.startswith("Category:"):
            # TODO: Implement fetching *from* a category (more complex)
            # For now, maybe use category name as search term?
            category_name = commons_tag.replace("Category:", "", 1)
            search_term = f"{name} {category_name}" if name else category_name
            image_url = await _fetch_commons_image_url(session, search_term)
            if image_url: source = "commons_category_search"
        else:
            # Assume it might be a relevant search term?
            search_term = f"{name} {commons_tag}" if name else commons_tag
            image_url = await _fetch_commons_image_url(session, search_term)
            if image_url: source = "commons_tag_search"

    # Strategy C: Use Wikidata ID (TODO: Implement SPARQL or entity data query)
    # if not image_url and wikidata_id:
    #    logger.debug(f"Attempting fetch via wikidata ID: {wikidata_id}")
    #    # image_url = await _fetch_image_from_wikidata(session, wikidata_id)
    #    # if image_url: source = "wikidata"
    #    pass # Placeholder for Wikidata implementation

    # Strategy D: Search by Name + Context (Fallback)
    if not image_url and name:
        search_term = f"{name}, {city}" if city else name
        logger.debug(f"Attempting fetch via Commons search: {search_term}")
        image_url = await _fetch_commons_image_url(session, search_term)
        if image_url: source = "commons_name_search"

    # 3. Cache the result (found URL or None if not found)
    await cache_image_url(conn, place_table, place_id, image_url, source)

    # 4. Return URL or default placeholder
    return image_url if image_url is not None else DEFAULT_IMAGE_PLACEHOLDER