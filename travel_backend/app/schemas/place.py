# app/schemas/place.py
from pydantic import BaseModel, HttpUrl, Field
from typing import Optional, List, Dict, Any
import datetime # Import datetime

# Schema for representing basic place info in a list
class PlaceBase(BaseModel):
    name: str
    latitude: float
    longitude: float
    category: str
    # Add other fields you definitely want in the list view
    address: Optional[str] = None

class PlaceInDBBase(PlaceBase):
    id: int
    city_id: Optional[int] = None # Include if useful for frontend context
    # Include image URL if we fetch it here later
    # image_url: Optional[HttpUrl] = None

    class Config:
        orm_mode = True # Pydantic V1. Use from_attributes = True for V2

# Schema returned by the GET /places/ endpoint list
class Place(PlaceInDBBase):
    # Add the images field, defaulting to an empty list
    images: List[HttpUrl] = [] # Will store URLs fetched from place_images

# We might need a more detailed schema later for GET /places/{place_id}
class PlaceDetail(Place): # Inherits from Place list schema
    osm_id: Optional[str] = None
    osm_type: Optional[str] = None
    website: Optional[HttpUrl] = None
    description: Optional[str] = None
    phone: Optional[str] = None
    opening_hours: Optional[str] = None # Or potentially a structured object
    cuisine: Optional[str] = None
    entry_fee: Optional[str] = None
    religion: Optional[str] = None
    denomination: Optional[str] = None
    attributes: Optional[Dict[str, Any]] = None # For the JSONB data
    created_at: Optional[datetime.datetime] = None # Include timestamps
    updated_at: Optional[datetime.datetime] = None
    # Add images field here when we implement image fetching for places
    # images: List[HttpUrl] = []