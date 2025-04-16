# app/utils.py
import math
from geopy.distance import geodesic # Use geopy for easier distance calculation

from passlib.context import CryptContext

def calculate_distance_km(lat1, lon1, lat2, lon2):
    """Calculates distance between two lat/lon points in kilometers using geopy."""
    if None in [lat1, lon1, lat2, lon2]:
        return float('inf') # Handle missing coordinates
    try:
        return geodesic((lat1, lon1), (lat2, lon2)).km
    except ValueError:
        return float('inf') # Handle invalid coordinates

def calculate_bounding_box(latitude, longitude, radius_km):
    """
    Calculates an approximate bounding box around a point.
    Note: This is a simplified approximation, less accurate near poles/dateline.
    For precise DB filtering, PostGIS is far superior.
    """
    if None in [latitude, longitude, radius_km]:
        return None

    # Constants (approximate)
    KM_PER_DEG_LAT = 111.0
    # Km per degree longitude varies with latitude
    km_per_deg_lon = 111.32 * math.cos(math.radians(latitude))

    if km_per_deg_lon <= 0: # Avoid division by zero at poles
        km_per_deg_lon = 0.001

    lat_delta = radius_km / KM_PER_DEG_LAT
    lon_delta = radius_km / km_per_deg_lon

    min_lat = latitude - lat_delta
    max_lat = latitude + lat_delta
    min_lon = longitude - lon_delta
    max_lon = longitude + lon_delta

    return {
        "min_lat": min_lat,
        "max_lat": max_lat,
        "min_lon": min_lon,
        "max_lon": max_lon,
    }

def get_pagination_params(page: int, size: int):
    """Calculates limit and offset, enforcing constraints."""
    from app.config import settings
    page = max(1, page) # Ensure page >= 1
    size = max(1, min(settings.max_page_size, size)) # Ensure 1 <= size <= max_size
    offset = (page - 1) * size
    return limit, offset, page, size # Return validated page/size too

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)