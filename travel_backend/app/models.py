# app/models.py
from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any, Union

# --- Base Models (Keep existing PlaceBase) ---
class PlaceBase(BaseModel):
    id: int
    name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    website: Optional[str] = None
    description: Optional[str] = None
    osm_id: Optional[int] = None
    image_url: Optional[str] = None # Ensure this exists
    address: Optional[str] = None # Keep address field
    tags: Optional[Dict[str, Any]] = None

    class Config:
        orm_mode = True

# --- Specific Place Types (Keep existing Landmark, NaturalWonder, RestaurantFood) ---
class Landmark(PlaceBase):
    category: str = Field("landmark", const=True)
    entry_fee: Optional[str] = None
    opening_hours: Optional[str] = None

class NaturalWonder(PlaceBase):
    category: str = Field("natural_wonder", const=True)
    entry_fee: Optional[str] = None
    opening_hours: Optional[str] = None

class RestaurantFood(PlaceBase):
    category: str = Field("restaurant_food", const=True)
    cuisine: Optional[str] = None
    opening_hours: Optional[str] = None

# --- Union Type (Keep existing Place) ---
Place = Union[Landmark, NaturalWonder, RestaurantFood]

# --- Pagination Response (Keep existing PaginatedPlacesResponse) ---
class PaginatedPlacesResponse(BaseModel):
    items: List[Place]
    total_items: int
    total_pages: int
    page: int
    size: int

# --- *** NEW MODELS FOR BEST-FOR-YOU *** ---
class RecommendedPlace(PlaceBase):
    # Include fields from the Place Union Type or inherit selectively
    # For simplicity, let's redefine needed fields + new ones
    id: int
    name: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    website: Optional[str] = None
    description: Optional[str] = None
    osm_id: Optional[int] = None
    tags: Optional[Dict[str, Any]] = None
    category: str # Which category it came from (landmark, etc.)

    # Recommendation specific fields
    # relevance_score: float = Field(..., description="Score indicating recommendation quality (higher is better)")
    relevance_score: Optional[float] = Field(None, description="...")
    reason: Optional[List[str]] = Field(None, description="Brief reasons for the recommendation")
    distance_km: Optional[float] = Field(None, description="Distance in KM if location provided")

    class Config:
        orm_mode = True # Allow creation from ORM/dict-like objects

class PaginatedRecommendedPlacesResponse(BaseModel):
    items: List[RecommendedPlace] # Use the new RecommendedPlace model
    total_items: int # Total potentially relevant items before ranking/pagination
    total_pages: int
    page: int
    size: int

# --- User Models ---
class UserBase(BaseModel):
    email: str = Field(..., example="user@example.com")
    full_name: Optional[str] = Field(None, example="Jane Doe")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, example="a_strong_password")

# Stored in DB (includes hashed password) - Not usually sent via API
class UserInDB(UserBase):
    id: int
    hashed_password: str
    is_active: bool = True
    is_superuser: bool = False
    created_at: Optional[Any] = None # Use Any for datetime compatibility if needed

    class Config:
        orm_mode = True

# Returned by API (omits password)
class User(UserBase):
    id: int
    is_active: bool = True
    # is_superuser: bool = False # Only include if needed by frontend/client

    class Config:
        orm_mode = True

# --- Token Models ---
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

# Data encoded within the JWT token
class TokenData(BaseModel):
    email: Optional[str] = None
    # Add other fields like user_id, scope if needed

# --- Refresh Token Request ---
class RefreshTokenRequest(BaseModel):
    refresh_token: str

class PlaceCategory(BaseModel):
   name: str = Field(..., description="Short identifier name (e.g., 'beach', 'museum')", example="beach")
   display_name: str = Field(..., description="User-friendly display name", example="Beaches")
   osm_key: str = Field(..., description="The primary OSM key used for this category", example="natural")
   osm_value: str = Field(..., description="The primary OSM value used for this category", example="beach")
   # icon_name: Optional[str] = Field(None, description="Identifier for a potential frontend icon", example="beach_icon") # Optional

# --- *** ADD NEW MODEL FOR USER PREFERENCES UPDATE *** ---
class UserPreferencesUpdate(BaseModel):
    interests: List[str] = Field(..., description="List of user interests (keywords)", example=["hiking", "museums", "ramen"])

CATEGORY_MAP = {
    # Base Categories (no specific tag filter needed beyond table)
    "landmark": {"table": "landmarks", "model": Landmark, "tags_filter": None},
    "natural_wonder": {"table": "natural_wonders", "model": NaturalWonder, "tags_filter": None},
    "restaurant_food": {"table": "restaurants_food", "model": RestaurantFood, "tags_filter": None},
    # Conceptual Categories mapping to a base table + specific tags
    "park": {"table": "natural_wonders", "model": NaturalWonder, "tags_filter": ("leisure", "park")},
    "beach": {"table": "natural_wonders", "model": NaturalWonder, "tags_filter": ("natural", "beach")},
    "museum": {"table": "landmarks", "model": Landmark, "tags_filter": ("tourism", "museum")},
    "castle": {"table": "landmarks", "model": Landmark, "tags_filter": ("historic", "castle")},
    "cafe": {"table": "restaurants_food", "model": RestaurantFood, "tags_filter": ("amenity", "cafe")},
    "restaurant": {"table": "restaurants_food", "model": RestaurantFood, "tags_filter": ("amenity", "restaurant")},
    "bar": {"table": "restaurants_food", "model": RestaurantFood, "tags_filter": ("amenity", "bar")},
    # Add more conceptual mappings here
}