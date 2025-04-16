# app/routers/places.py
import math
import logging
import time
from fastapi import APIRouter, Depends, Path, Query, HTTPException, status
from typing import List, Optional
import asyncpg # Ensure asyncpg is imported if needed directly, though usually just for type hinting

# Import the context manager function, not the connection object directly
from app.database import get_db_connection
# Import the Pydantic models and CRUD functions
from app.models import PaginatedRecommendedPlacesResponse, Place, PaginatedPlacesResponse, Landmark, NaturalWonder, RecommendedPlace, RestaurantFood,PlaceCategory # Make sure all needed models are imported
from app.crud import get_best_places_for_user, get_places_near_location, get_places_by_type, get_top_places
from app.config import settings
from app.security import get_current_active_user


router = APIRouter(
    prefix="/places",
    tags=["Places"],
    
)

logger = logging.getLogger(__name__)

# ============================================================
# CORRECTED ROUTE HANDLERS using 'async with'
# ============================================================

@router.get("/nearby", response_model=PaginatedPlacesResponse)
async def read_places_nearby(
    latitude: float = Query(..., description="Latitude...", ge=-90, le=90),
    longitude: float = Query(..., description="Longitude...", ge=-180, le=180),
    radius_km: float = Query(5.0, description="Search radius...", ge=0.1, le=50),
    category: Optional[str] = Query(None, description="Filter by category..."),
    page: int = Query(1, description="Page number", ge=1),
    size: int = Query(settings.default_page_size, description="Items per page", ge=1, le=settings.max_page_size),
    # Inject the context manager function
    db_conn_manager = Depends(get_db_connection)
):
    """
    Retrieve places near a specific location (latitude, longitude) within a given radius.
    """
    try:
        # *** Use 'async with' to acquire the connection ***
        async with db_conn_manager as conn: # 'conn' is now the actual asyncpg.Connection
            # Pass the acquired 'conn' to the CRUD function
            items, total_items = await get_places_near_location(
                conn=conn,
                latitude=latitude,
                longitude=longitude,
                radius_km=radius_km,
                page=page,
                size=size,
                category=category
            )

        total_pages = math.ceil(total_items / size) if size > 0 else 0

        return PaginatedPlacesResponse(
            items=items,
            total_items=total_items,
            total_pages=total_pages,
            page=page,
            size=len(items)
        )
    except Exception as e:
        logger.exception(f"Error fetching nearby places: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching nearby places.",
        )


@router.get("/by-type", response_model=PaginatedPlacesResponse)
async def read_places_by_type(
    osm_key: str = Query(..., description="OSM tag key..."),
    osm_value: str = Query(..., description="OSM tag value..."),
    city_id: Optional[int] = Query(None, description="Filter by city ID..."),
    page: int = Query(1, description="Page number", ge=1),
    size: int = Query(settings.default_page_size, description="Items per page", ge=1, le=settings.max_page_size),
     # Inject the context manager function
    db_conn_manager = Depends(get_db_connection)
):
    """
    Retrieve places based on specific OpenStreetMap tag key/value pairs.
    """
    try:
        # *** Use 'async with' to acquire the connection ***
        async with db_conn_manager as conn: # 'conn' is now the actual asyncpg.Connection
             # Pass the acquired 'conn' to the CRUD function
            items, total_items = await get_places_by_type(
                conn=conn,
                place_type_key=osm_key,
                place_type_value=osm_value,
                city_id=city_id,
                page=page,
                size=size
            )

        total_pages = math.ceil(total_items / size) if size > 0 else 0

        return PaginatedPlacesResponse(
            items=items,
            total_items=total_items,
            total_pages=total_pages,
            page=page,
            size=len(items)
        )
    except Exception as e:
        logger.exception(f"Error fetching places by type: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching places by type.",
        )


@router.get("/top", response_model=List[RecommendedPlace]) # <-- Use RecommendedPlace model
async def read_top_places(
    criteria: str = Query("recent", description="Criteria for 'top' (e.g., 'recent', 'popular' - currently only 'recent' placeholder)"),
    time_window: str = Query("week", description="Time window (e.g., 'day', 'week' - currently ignored)"),
    limit: int = Query(10, description="Maximum number...", ge=1, le=50),
    # Add optional location parameters
    latitude: Optional[float] = Query(None, description="Center latitude for location filter (optional)", ge=-90, le=90),
    longitude: Optional[float] = Query(None, description="Center longitude for location filter (optional)", ge=-180, le=180),
    radius_km: Optional[float] = Query(None, description="Radius for location filter (km, required if lat/lon provided)", ge=0.5, le=100),
    # Inject the context manager function
    db_conn_manager = Depends(get_db_connection)
):
    """
    Retrieve 'top' places based on criteria, optionally filtered by location.
    Includes reason for recommendation and attempts to find image URL from tags.
    """
    # --- Validation for Location Params ---
    if (latitude is not None or longitude is not None or radius_km is not None) and \
       not (latitude is not None and longitude is not None and radius_km is not None):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="If filtering by location, latitude, longitude, and radius_km are all required.",
        )
    if latitude is None: # Ensure radius is None if no coords
         radius_km = None

    # --- Validation for Criteria ---
    if criteria not in ["recent"]: # Add other valid criteria here when implemented
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid criteria specified. Currently only 'recent' is supported.",
        )

    try:
        async with db_conn_manager as conn:
            # Pass all parameters to the updated CRUD function
            items = await get_top_places(
                conn,
                criteria,
                time_window,
                limit,
                latitude, # Pass location params
                longitude,
                radius_km
            )
        return items
    except Exception as e:
        logger.exception(f"Error fetching top places: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching top places.",
        )
    
@router.get("/best-for-you/{user_id}", response_model=PaginatedRecommendedPlacesResponse)
async def read_best_places_for_user(
    user_id: int = Path(..., description="Dummy User ID for preference profile", ge=1),
    latitude: Optional[float] = Query(None, description="User's current latitude (optional)", ge=-90, le=90),
    longitude: Optional[float] = Query(None, description="User's current longitude (optional)", ge=-180, le=180),
    radius_km: Optional[float] = Query(10.0, description="Search radius if location provided (km)", ge=0.5, le=100),
    category: Optional[str] = Query(None, description="Filter by category (landmark, natural_wonder, restaurant_food)"),
    interests: Optional[List[str]] = Query(None, description="List of user interests (e.g., hiking, museums)"),
    page: int = Query(1, description="Page number", ge=1),
    size: int = Query(settings.default_page_size, description="Items per page", ge=1, le=settings.max_page_size),
    db_conn_manager = Depends(get_db_connection)
):
    """
    Retrieve personalized place recommendations for a given (dummy) user ID.
    Considers location, category, and interests (based on dummy profiles).
    """
    # Basic validation for location params if provided together
    if (latitude is None and longitude is not None) or (latitude is not None and longitude is None):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Both latitude and longitude must be provided if location is used.")
    if latitude is None and longitude is None:
        radius_km = None # No radius if no location

    try:
        async with db_conn_manager as conn:
            items, total_items = await get_best_places_for_user(
                conn=conn,
                user_id=user_id,
                latitude=latitude,
                longitude=longitude,
                radius_km=radius_km,
                category=category,
                interests=interests,
                page=page,
                size=size
            )

        total_pages = math.ceil(total_items / size) if size > 0 else 0

        return PaginatedRecommendedPlacesResponse(
            items=items,
            total_items=total_items,
            total_pages=total_pages,
            page=page,
            size=len(items) # Actual items returned
        )
    except Exception as e:
        logger.exception(f"Error fetching recommendations for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching recommendations.",
        )
    
SUPPORTED_CATEGORIES = [
    PlaceCategory(name="beach", display_name="Beaches", osm_key="natural", osm_value="beach"),
    PlaceCategory(name="park", display_name="Parks", osm_key="leisure", osm_value="park"),
    PlaceCategory(name="museum", display_name="Museums", osm_key="tourism", osm_value="museum"),
    PlaceCategory(name="restaurant", display_name="Restaurants", osm_key="amenity", osm_value="restaurant"),
    PlaceCategory(name="cafe", display_name="Cafes", osm_key="amenity", osm_value="cafe"),
    PlaceCategory(name="castle", display_name="Castles", osm_key="historic", osm_value="castle"),
    PlaceCategory(name="mountain", display_name="Mountains/Peaks", osm_key="natural", osm_value="peak"),
    PlaceCategory(name="historic_site", display_name="Historic Sites", osm_key="historic", osm_value="archaeological_site"), # Example
    PlaceCategory(name="waterfall", display_name="Waterfalls", osm_key="natural", osm_value="waterfall"),
    PlaceCategory(name="bar", display_name="Bars & Pubs", osm_key="amenity", osm_value="bar"), # Combining bar/pub
    # Add more as needed based on your data and desired UI presentation
]

@router.get("/categories", response_model=List[PlaceCategory], tags=["Categories"])
async def get_supported_categories():
    """Returns a list of supported place categories for filtering/browsing."""
    return SUPPORTED_CATEGORIES