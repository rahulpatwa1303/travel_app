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