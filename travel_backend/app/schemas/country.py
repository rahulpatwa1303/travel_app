from pydantic import BaseModel
from typing import Optional

# Shared base properties
class CountryBase(BaseModel):
    name: str

# Properties to receive via API on creation (if needed later)
# class CountryCreate(CountryBase):
#     pass

# Properties stored in DB
class CountryInDBBase(CountryBase):
    id: int

    class Config:
        orm_mode = True # For Pydantic V1. Use from_attributes = True for V2

# Properties to return to client
class Country(CountryInDBBase):
    pass