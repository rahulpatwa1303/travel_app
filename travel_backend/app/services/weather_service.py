# app/services/weather_service.py
import httpx
import logging
from typing import Optional, Dict, Any
from app.core.config import settings # Assuming OWM_API_KEY is in settings

logger = logging.getLogger(__name__)
WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather"

async def get_current_weather(lat: float, lon: float) -> Optional[Dict[str, Any]]:
    """Fetches current weather from OpenWeatherMap."""
    if not settings.OWM_API_KEY: # Check if API key is configured
        logger.warning("OpenWeatherMap API Key (OWM_API_KEY) not configured in settings.")
        return None

    params = {
        "lat": lat,
        "lon": lon,
        "appid": settings.OWM_API_KEY,
        "units": "metric" # Or "imperial"
    }
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(WEATHER_API_URL, params=params)
            response.raise_for_status() # Raise HTTP errors
            logger.info(f"OpenWeatherMap API response status: {response.status_code} for lat={lat}, lon={lon}")
            return response.json()
    except httpx.RequestError as exc:
        logger.error(f"HTTP error fetching weather for lat={lat}, lon={lon}: {exc}")
        return None
    except Exception as e:
        logger.error(f"Error parsing weather data for lat={lat}, lon={lon}: {e}", exc_info=True)
        return None