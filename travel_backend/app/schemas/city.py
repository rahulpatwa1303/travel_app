from pydantic import BaseModel, HttpUrl
from typing import List, Optional
from .country import Country # Import the Country schema

# Shared base properties
class CityBase(BaseModel):
    name: str

# Properties to receive via API on creation (if needed later)
# class CityCreate(CityBase):
#     country_id: int # Or maybe country name, then lookup ID

# Properties stored in DB
class CityInDBBase(CityBase):
    id: int
    # country_id: int # We might not expose this directly

    class Config:
        orm_mode = True # For Pydantic V1. Use from_attributes = True for V2

# Properties to return to client for the 'popular cities' endpoint
class City(CityInDBBase):
     # Include the nested Country object in the response
     # Pydantic will automatically populate this from the City.country relationship
    country: Country
    images: List[HttpUrl] = []