import json
import requests
import urllib.parse

# --- Helper Functions ---

def get_filename_from_wikidata(wikidata_id):
    """Fetches the main image filename (P18) from a Wikidata item."""
    try:
        endpoint_url = "https://www.wikidata.org/w/api.php"
        params = {
            "action": "wbgetclaims",
            "format": "json",
            "entity": wikidata_id,
            "property": "P18" # P18 is the property for "image"
        }
        # Add a User-Agent header
        headers = {'User-Agent': 'MyLandmarkImageFetcher/1.0 (contact@example.com)'} # Be polite, identify your bot
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()

        claims = data.get("claims", {}).get("P18", [])
        if claims:
            # Get the filename from the first claim
            filename = claims[0].get("mainsnak", {}).get("datavalue", {}).get("value")
            if filename:
                # Return the raw filename
                return filename.replace(" ", "_") # Replace spaces with underscores for consistency
    except requests.exceptions.RequestException as e:
        print(f"Error fetching Wikidata for {wikidata_id}: {e}")
    except Exception as e:
        print(f"Error processing Wikidata for {wikidata_id}: {e}")
    return None

def search_wikimedia_commons_for_filename(query):
    """Searches Wikimedia Commons and returns the filename of the top result."""
    try:
        endpoint_url = "https://commons.wikimedia.org/w/api.php"
        params = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": query,
            "srnamespace": 6, # File namespace
            "srlimit": 1
        }
        headers = {'User-Agent': 'MyLandmarkImageFetcher/1.0 (contact@example.com)'}
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()

        search_results = data.get("query", {}).get("search", [])
        if search_results:
            title = search_results[0].get("title")
            if title and title.startswith("File:"):
                # Extract filename from title (e.g., "File:My_Image.jpg" -> "My_Image.jpg")
                return title.split(":", 1)[1].replace(" ", "_")
    except requests.exceptions.RequestException as e:
        print(f"Error searching Wikimedia Commons for '{query}': {e}")
    except Exception as e:
        print(f"Error processing Wikimedia Commons search for '{query}': {e}")
    return None

def get_wikimedia_image_direct_url(filename):
    """Gets the direct image URL from Wikimedia Commons using the filename."""
    if not filename:
        return None
    try:
        endpoint_url = "https://commons.wikimedia.org/w/api.php"
        params = {
            "action": "query",
            "format": "json",
            "titles": f"File:{filename}", # Use the File: prefix here
            "prop": "imageinfo",
            "iiprop": "url" # Request the direct URL
        }
        headers = {'User-Agent': 'MyLandmarkImageFetcher/1.0 (contact@example.com)'}
        response = requests.get(endpoint_url, params=params, headers=headers, timeout=15)
        response.raise_for_status()
        data = response.json()

        # Navigate through the nested JSON structure
        pages = data.get("query", {}).get("pages", {})
        for page_id in pages:
            # Check if page exists (page_id != "-1")
            if page_id != "-1" and "imageinfo" in pages[page_id]:
                image_info = pages[page_id].get("imageinfo", [])
                if image_info:
                    # Get the URL from the first imageinfo entry
                    return image_info[0].get("url")
        # If loop completes without finding URL
        print(f"Could not find direct URL for filename: {filename}")
        return None # Explicitly return None if not found
    except requests.exceptions.RequestException as e:
        print(f"Error fetching imageinfo for '{filename}': {e}")
    except Exception as e:
        print(f"Error processing imageinfo for '{filename}': {e}")
    return None

# --- Main Processing Logic ---

input_data = [
    # ... your list of landmark dictionaries here ...
    {
        "id": 123220,
        "name": "House of Culture",
        "latitude": 17.4885915,
        "longitude": -88.1870883,
        "website": None,
        "description": None,
        "osm_id": 130793104,
        "tags": {
            "name": "House of Culture",
            "tourism": "museum",
            "building": "yes",
            "addr:city": "Belize City" # Added city for better search context
        },
        "category": "landmark",
        "relevance_score": None,
        "reason": [
            "Recently added landmark"
        ],
        "distance_km": None
    },
    {
        "id": 123223,
        "name": "Holy Redeemer Cathedral",
        "latitude": 17.4963494,
        "longitude": -88.1870466,
        "website": "https://www.holyredeemerbelize.org/",
        "description": None,
        "osm_id": 259180757,
        "tags": {
            "name": "Holy Redeemer Cathedral",
            "phone": "+501 227-2122",
            "source": "Bing;local knowledge;https://www.holyredeemerbelize.org/",
            "amenity": "place_of_worship",
            "diocese": "Belize City-Belmopan",
            "name:es": "Catedral del Santo Redentor",
            "website": "https://www.holyredeemerbelize.org/",
            "alt_name": "Holy Redeemer Catholic Church",
            "building": "church",
            "religion": "christian",
            "wikidata": "Q4163667", # <-- Has Wikidata ID
            "addr:city": "Belize City",
            "wikipedia": "en:Holy Redeemer Cathedral", # <-- Has Wikipedia link
            "start_date": "1858",
            "addr:street": "North Front Street",
            "alt_name:es": "Iglesia Católica del Santo Redentor",
            "addr:city:es": "Ciudad de Belice",
            "addr:postbox": "616",
            "denomination": "roman_catholic",
            "addr:housenumber": "144"
        },
        "category": "landmark",
        "relevance_score": None,
        "reason": [
            "Recently added landmark"
        ],
        "distance_km": None
    },
     {
        "id": 123217,
        "name": "Winner Chapel International",
        "latitude": 17.4978273,
        "longitude": -88.1972459,
        "website": None,
        "description": None,
        "osm_id": 12016030240,
        "tags": {
            "name": "Winner Chapel International",
            "image": "https://commons.wikimedia.org/wiki/File:Radio_Tower3.jpg", # <-- Has image tag (page URL)
            "man_made": "tower",
            "addr:city": "Belize",
            "tower:type": "communication",
            "tower:construction": "freestanding",
            "communication:radio": "yes"
        },
        "category": "landmark",
        "relevance_score": None,
        "reason": [
            "Recently added landmark"
        ],
        "distance_km": None
    },
    {
        "id": 123219,
        "name": "St. John's Anglican Cathedral",
        "latitude": 17.4887398,
        "longitude": -88.1877968,
        "website": None,
        "description": None,
        "osm_id": 130793100,
        "tags": {
            "name": "St. John's Anglican Cathedral",
            "amenity": "place_of_worship",
            "building": "yes",
            "religion": "christian",
            "wikidata": "Q4163413", # <-- Has Wikidata ID
            "addr:city": "Belize City",
            "wikipedia": "en:St. John's Cathedral (Belize City)", # <-- Has Wikipedia link
            "start_date": "1812",
            "addr:street": "Regent Street",
            "denomination": "anglican",
            "old_name:1812-1891": "St. John's Church"
        },
        "category": "landmark",
        "relevance_score": None,
        "reason": [
            "Recently added landmark"
        ],
        "distance_km": None
    },
    # ... add the rest of your data ...
     {
        "id": 123215,
        "name": "Digi",
        "latitude": 17.4844024,
        "longitude": -88.2436094,
        "website": None,
        "description": None,
        "osm_id": 10751317272,
        "tags": {
            "name": "Digi",
            "image": "https://commons.wikimedia.org/wiki/File:Digicel.jpg", # <-- Has image tag (page URL)
            "man_made": "tower",
            "tower:type": "communication",
            "tower:construction": "freestanding",
            "communication:mobile_phone": "yes"
        },
        "category": "landmark",
        "relevance_score": None,
        "reason": [
            "Recently added landmark"
        ],
        "distance_km": None
    },
]

output_data = []

for landmark in input_data:
    print(f"Processing: {landmark['name']} (ID: {landmark['id']})")
    image_url = None
    filename = None
    tags = landmark.get("tags", {})

    # 1. Check for existing 'image' tag (often a page URL, extract filename)
    if tags and 'image' in tags:
        image_tag_value = tags['image']
        # Basic check if it looks like a Commons file page URL
        if isinstance(image_tag_value, str) and image_tag_value.startswith("https://commons.wikimedia.org/wiki/File:"):
             try:
                # Extract filename from URL, decode URL encoding, replace underscores
                potential_filename = urllib.parse.unquote(image_tag_value.split(":")[-1])#.replace("_", " ")
                filename = potential_filename
                print(f"  Found filename '{filename}' from image tag.")
             except Exception as e:
                 print(f"  Error parsing filename from image tag '{image_tag_value}': {e}")
        elif isinstance(image_tag_value, str) and not image_tag_value.startswith("http"):
             # Assume it might be just the filename directly
             filename = image_tag_value.replace(" ", "_")
             print(f"  Found potential filename '{filename}' directly in image tag.")


    # 2. Check for 'wikidata' tag if no filename yet
    if not filename and tags and 'wikidata' in tags:
        wikidata_id = tags['wikidata']
        print(f"  Checking Wikidata ({wikidata_id})...")
        filename = get_filename_from_wikidata(wikidata_id)
        if filename:
             print(f"  Found filename via Wikidata: {filename}")

    # 3. Check for 'wikipedia' tag (can sometimes be used to find Wikidata/Commons)
    # More complex: would need to query Wikipedia API -> get Wikidata ID -> get filename
    # Skipping this step for now, as Wikidata is the more direct link.

    # 4. Fallback: Search Wikimedia Commons by name (+ city) if still no filename
    if not filename:
        search_term = landmark['name']
        if tags and 'addr:city' in tags:
            search_term += f" {tags['addr:city']}"
        elif 'addr:country' in tags: # Use country if city not available
             search_term += f" {tags['addr:country']}"

        print(f"  Searching Wikimedia Commons for '{search_term}'...")
        filename = search_wikimedia_commons_for_filename(search_term)
        if filename:
             print(f"  Found filename via Wikimedia search: {filename}")

    # 5. If we have a filename, get the direct URL
    if filename:
        print(f"  Attempting to get direct URL for filename: {filename}")
        image_url = get_wikimedia_image_direct_url(filename)
        if image_url:
            print(f"  Success! Direct URL: {image_url}")
        else:
            print(f"  Failed to get direct URL for filename: {filename}")
            # Keep the Commons page URL as a fallback if we extracted it initially? Optional.
            if tags and 'image' in tags and tags['image'].startswith("https://commons.wikimedia.org/wiki/File:"):
                 image_url = tags['image'] # Fallback to page URL if direct fails
                 print(f"  Falling back to page URL from tag: {image_url}")


    # Add the image_url (even if None) to the landmark data
    landmark['image_url'] = image_url
    output_data.append(landmark)
    print("-" * 20) # Separator for clarity

# Print the final result (or save to a file)
print("\n--- Enriched Data ---")
print(json.dumps(output_data, indent=4))

# Example: Save to a new JSON file
# with open('landmarks_with_direct_images.json', 'w') as f:
#     json.dump(output_data, f, indent=4)