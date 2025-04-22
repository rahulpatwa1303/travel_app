# app/schemas/weather.py
from pydantic import BaseModel, Field
from typing import Optional, List

# Define based on OpenWeatherMap (or chosen API) response structure
# Example simplified structure:
class WeatherCondition(BaseModel):
    main: Optional[str] = None # e.g., "Clear", "Clouds", "Rain"
    description: Optional[str] = None
    icon: Optional[str] = None # Icon code

class MainWeather(BaseModel):
    temp: Optional[float] = None
    feels_like: Optional[float] = Field(None, alias="feelsLike") # Handle alias if needed
    temp_min: Optional[float] = Field(None, alias="tempMin")
    temp_max: Optional[float] = Field(None, alias="tempMax")
    pressure: Optional[int] = None
    humidity: Optional[int] = None

class Wind(BaseModel):
    speed: Optional[float] = None
    deg: Optional[int] = None

class CurrentWeather(BaseModel):
    weather: Optional[List[WeatherCondition]] = None
    main: Optional[MainWeather] = None
    visibility: Optional[int] = None
    wind: Optional[Wind] = None
    dt: Optional[int] = None # Timestamp of data calculation
    timezone: Optional[int] = None # Shift in seconds from UTC
    name: Optional[str] = None # City name from weather API

class Config:
     allow_population_by_field_name = True # Allow aliases like feelsLike
     orm_mode = False # This is not directly mapped from DB model

# --- Units Schemas (Optional but good practice) ---
class HourlyUnits(BaseModel):
    time: Optional[str] = None
    temperature_2m: Optional[str] = Field(None, alias="temperature2m")
    is_day: Optional[str] = Field(None, alias="isDay")
    sunshine_duration: Optional[str] = Field(None, alias="sunshineDuration")
    weathercode: Optional[str] = None
    precipitation_probability: Optional[str] = Field(None, alias="precipitationProbability")
    # Add other units if you request more hourly variables

    class Config:
        allow_population_by_field_name = True

class DailyUnits(BaseModel):
    time: Optional[str] = None
    sunrise: Optional[str] = None
    sunset: Optional[str] = None
    # Add other units if you request more daily variables

# --- Data Schemas ---
class HourlyData(BaseModel):
    time: Optional[List[str]] = None
    temperature_2m: Optional[List[Optional[float]]] = Field(None, alias="temperature2m") # List can contain nulls
    is_day: Optional[List[Optional[int]]] = Field(None, alias="isDay") # 0 or 1
    sunshine_duration: Optional[List[Optional[float]]] = Field(None, alias="sunshineDuration") # In seconds
    weathercode: Optional[List[Optional[int]]] = None # WMO Weather interpretation codes
    precipitation_probability: Optional[List[Optional[int]]] = Field(None, alias="precipitationProbability") # Percentage
    # Add other variables corresponding to HourlyUnits

    class Config:
        allow_population_by_field_name = True

class DailyData(BaseModel):
    time: Optional[List[str]] = None # List of dates (YYYY-MM-DD)
    sunrise: Optional[List[Optional[str]]] = None # List of ISO8601 strings
    sunset: Optional[List[Optional[str]]] = None # List of ISO8601 strings
     # Add other variables corresponding to DailyUnits

# --- Main Open-Meteo Response Schema ---
class OpenMeteoForecastResponse(BaseModel):
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    generationtime_ms: Optional[float] = Field(None, alias="generationtimeMs")
    utc_offset_seconds: Optional[int] = Field(None, alias="utcOffsetSeconds")
    timezone: Optional[str] = None
    timezone_abbreviation: Optional[str] = Field(None, alias="timezoneAbbreviation")
    elevation: Optional[float] = None
    hourly_units: Optional[HourlyUnits] = Field(None, alias="hourlyUnits")
    hourly: Optional[HourlyData] = None
    daily_units: Optional[DailyUnits] = Field(None, alias="dailyUnits")
    daily: Optional[DailyData] = None

    class Config:
        allow_population_by_field_name = True