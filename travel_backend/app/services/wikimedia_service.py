import logging
import httpx
from typing import Optional, List

# Wikimedia Commons API endpoint
WIKIMEDIA_API_URL = "https://commons.wikimedia.org/w/api.php"

# Be a good citizen - set a user agent
HTTP_HEADERS = {
    "User-Agent": "MyTravelApp/1.0 (contact@example.com)" # Change this!
}

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO) # Configure basic logging


async def search_wikimedia_image(query: str) -> Optional[str]:
    """
    Searches Wikimedia Commons for an image related to the query.
    Returns the URL of the first suitable image found, or None.
    """
    params = {
        "action": "query",
        "format": "json",
        "list": "search",
        "srsearch": query,
        "srnamespace": "6",  # File namespace
        "srlimit": "5",     # Limit results
        "srprop": "size|url", # Request properties (though direct URL isn't always available here)
        "origin": "*", # Handle CORS if calling from browser, okay for backend
    }

    try:
        async with httpx.AsyncClient(headers=HTTP_HEADERS) as client:
            response = await client.get(WIKIMEDIA_API_URL, params=params)
            response.raise_for_status()  # Raise exception for bad status codes
            data = response.json()

            search_results = data.get("query", {}).get("search", [])

            if not search_results:
                return None

            # Try to get image info for the first result
            first_result_title = search_results[0].get("title")
            if not first_result_title:
                return None

            # Need a second query to get the actual image URL from the file title
            image_info_params = {
                "action": "query",
                "format": "json",
                "titles": first_result_title,
                "prop": "imageinfo",
                "iiprop": "url|size|mime", # Get URL, size, MIME type
                "origin": "*",
            }
            info_response = await client.get(WIKIMEDIA_API_URL, params=image_info_params)
            info_response.raise_for_status()
            info_data = info_response.json()

            pages = info_data.get("query", {}).get("pages", {})
            if not pages: return None

            # Page ID is variable, get the first page data
            page_id = list(pages.keys())[0]
            image_info = pages[page_id].get("imageinfo", [])

            if image_info:
                # Prioritize larger images, check MIME type?
                # Simple approach: take the first one
                img_url = image_info[0].get("url")
                # Basic check for common image types
                if img_url and image_info[0].get("mime", "").startswith("image/"):
                     # Consider adding width/height check here later if needed
                    return img_url

    except httpx.RequestError as exc:
        print(f"HTTP error occurred while searching Wikimedia: {exc}")
        # Log the error properly in a real app
    except Exception as e:
        print(f"An error occurred during Wikimedia search: {e}")
        # Log the error

    return None


async def get_city_image_url(city_name: str, country_name: str) -> Optional[str]:
    """
    Tries different search queries to find a representative city image on Wikimedia.
    """
    # Try specific queries first
    queries = [
        f"{city_name} skyline",
        f"{city_name} {country_name} landmark",
        f"{city_name} city",
        city_name # Broad fallback
    ]
    for query in queries:
        image_url = await search_wikimedia_image(query)
        if image_url:
            return image_url
    return None

async def get_place_image_url(place_name: str, category: Optional[str] = None, city_name: Optional[str] = None) -> Optional[str]:
    """
    Tries different search queries to find a representative place image on Wikimedia.
    """
    queries = []
    if city_name:
        queries.append(f'"{place_name}", {city_name}') # Quote place name if it has spaces
    if category:
        queries.append(f"{place_name}, {category}")
    queries.append(place_name) # Fallback

    # Remove duplicates just in case
    unique_queries = list(dict.fromkeys(queries))

    for query in unique_queries:
        logger.info(f"Wikimedia search query: {query}") # Log the query being tried
        image_url = await search_wikimedia_image(query)
        if image_url:
            return image_url
    return None