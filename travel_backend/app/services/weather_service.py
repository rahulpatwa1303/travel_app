# app/services/weather_service.py
import httpx
import logging
from typing import Optional, Dict, Any
from app.core.config import settings # Assuming OWM_API_KEY is in settings

logger = logging.getLogger(__name__)
WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather"
WEATHER_API_URL_OPEN_METEO = "https://api.open-meteo.com/v1/forecast"

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
    

async def get_open_meteo_forecast_data(lat: float, lon: float) -> Optional[Dict[str, Any]]:
    """
    Fetches hourly forecast (temperature, is_day, sunshine) and daily
    sunrise/sunset times using Open-Meteo API.
    """
    params = {
        "latitude": lat,
        "longitude": lon,
        "daily": "sunrise,sunset", # Request daily sunrise/sunset
        # Request specific hourly variables
        "hourly": "temperature_2m,is_day,sunshine_duration,weathercode,precipitation_probability",
        "forecast_days": 1, # Get forecast only for the current day (+ next few hours technically)
        "timezone": "auto" # Automatically detect timezone based on lat/lon
    }
    # Use shared client if possible, or create one
    async with httpx.AsyncClient() as client:
        try:
            logger.debug(f"Requesting Open-Meteo API for lat={lat}, lon={lon}")
            response = await client.get(WEATHER_API_URL_OPEN_METEO, params=params)
            response.raise_for_status()
            logger.info(f"Open-Meteo API response status: {response.status_code} for lat={lat}, lon={lon}")
            return response.json() # Return the raw JSON response
        except httpx.RequestError as exc:
            logger.error(f"HTTP error fetching Open-Meteo weather for lat={lat}, lon={lon}: {exc}")
            return None
        except Exception as e:
            logger.error(f"Error parsing Open-Meteo weather data for lat={lat}, lon={lon}: {e}", exc_info=True)
            return None