from fastapi import APIRouter, BackgroundTasks, Depends, Path, Query, HTTPException,status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Any

from app import crud, schemas # Import top-level crud and schemas
from app.api import deps # Import dependencies (like get_db)
from app.core.config import settings # Import settings for defaults
from app.schemas import City as CitySchema # Import and potentially alias
from app.schemas import City as CityListSchema # Schema for list
from app.schemas import CityDetail as CityDetailSchema # Schema for detail
from app.db import models

router = APIRouter()

@router.get(
    "/popular",
    response_model=List[CitySchema], # Response uses the schema
    summary="Get Popular Cities with Images (Optimized)",
    description="Retrieves a list of popular cities with images. Fetches missing images in the background.",
)
async def read_popular_cities(
    background_tasks: BackgroundTasks, # Inject BackgroundTasks dependency
    db: AsyncSession = Depends(deps.get_db),
    limit: int = Query(
        settings.DEFAULT_PAGE_SIZE,
        ge=1,
        le=settings.MAX_PAGE_SIZE,
        description="Maximum number of cities to return."
    ),
    offset: int = Query(
        0,
        ge=0,
        description="Number of cities to skip."
    ),
    country: Optional[str] = Query(
        None,
        description="Filter cities by country name (case-insensitive, partial match)."
    ),
) -> Any:
    """
    Retrieves popular cities based on pre-populated data.

    - Fetches existing images efficiently.
    - Triggers **background tasks** to fetch images from Wikimedia if missing.
    - Supports pagination (`limit`, `offset`) and filtering (`country`).
    """
    # Call the optimized CRUD function, passing background_tasks object
    cities_data = await crud.crud_city.get_popular_cities_optimized(
        db=db,
        background_tasks=background_tasks, # Pass it here
        country_name=country,
        skip=offset,
        limit=limit
    )
    # FastAPI automatically validates the returned list of dicts against List[CitySchema]
    return cities_data

# You can add other city-related endpoints to this router later
# e.g., GET /cities/{city_id}
@router.get(
    "/{city_id}",
    response_model=CityDetailSchema,
    summary="Get City Details",
    description="Retrieves detailed information for a specific city, including current weather.",
    responses={404: {"description": "City not found"}}
)
async def read_city_detail(
    background_tasks: BackgroundTasks, # Needed for underlying image/detail fetching
    city_id: int = Path(..., title="The ID of the city to retrieve", ge=1),
    db: AsyncSession = Depends(deps.get_db),
) -> Any:
    """
    Retrieves comprehensive details for a single city, including:
    - Basic info (name, country)
    - Cached images
    - Cached description, travel info (if available)
    - Live or recently cached weather data
    """
    # city_details = await crud.crud_city.get_city_details(
    #     db=db, city_id=city_id, background_tasks=background_tasks
    # )

    city_details = await crud.crud_city.get_city_details_with_open_meteo(
        db=db, city_id=city_id, background_tasks=background_tasks
    )

    if not city_details:
        raise HTTPException(status_code=404, detail="City not found")

    # FastAPI validates the returned dict against CityDetailSchema
    return city_details


@router.post(
    "/me/favorite-cities/{city_id}",
    status_code=status.HTTP_200_OK, # Return 200 OK if added or already exists
    summary="Favorite a City",
    responses={
        status.HTTP_404_NOT_FOUND: {"description": "City not found"},
    },
    # No response body needed on success
)
async def favorite_city(
    *,
    db: AsyncSession = Depends(deps.get_db),
    city_id: int = Path(..., title="The ID of the city to favorite", ge=1),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> None:
    """Marks a city as a favorite (wishlist) for the current user."""
    favorite_city_assoc = await crud.crud_user_activity.add_city_favorite(
        db=db, user_id=current_user.id, city_id=city_id
    )
    if favorite_city_assoc is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="City not found")
    return None


@router.delete(
    "/me/favorite-cities/{city_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Unfavorite a City",
    responses={
        status.HTTP_404_NOT_FOUND: {"description": "City not found or not favorited"},
    }
)
async def unfavorite_city(
    *,
    db: AsyncSession = Depends(deps.get_db),
    city_id: int = Path(..., title="The ID of the city to unfavorite", ge=1),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> None:
    """Removes a city from the current user's favorites."""
    removed = await crud.crud_user_activity.remove_city_favorite(
        db=db, user_id=current_user.id, city_id=city_id
    )
    if not removed:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="City not found or not favorited")
    return None


@router.get(
    "/me/favorite-cities",
    response_model=List[CitySchema], # Use the standard City list schema
    summary="Get Favorite Cities"
)
async def read_favorite_cities(
    *,
    db: AsyncSession = Depends(deps.get_db),
    limit: int = Query(100, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Retrieves the list of cities favorited by the current user."""
    cities = await crud.crud_user_activity.get_favorite_cities(
        db=db, user_id=current_user.id, skip=offset, limit=limit
    )
    # FastAPI/Pydantic handles conversion using CitySchema's orm_mode
    return cities


@router.get(
    "/me/favorite-cities/ids",
    response_model=List[int],
    summary="Get Favorite City IDs"
)
async def read_favorite_city_ids(
    *,
    db: AsyncSession = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Retrieves only the IDs of cities favorited by the current user."""
    ids = await crud.crud_user_activity.get_favorite_city_ids(db=db, user_id=current_user.id)
    return ids

@router.get(
    "/", # Route path is '/' relative to router prefix '/cities'
    response_model=List[CitySchema], # Use the standard City list schema
    summary="Search Cities",
    description="Retrieve a list of cities, filterable by name query and/or country."
)
async def search_cities_endpoint(
    db: AsyncSession = Depends(deps.get_db),
    limit: int = Query(
        settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE,
        description="Maximum number of cities to return."
    ),
    offset: int = Query(
        0, ge=0, description="Number of cities to skip."
    ),
    country: Optional[str] = Query(
        None, description="Filter cities by country name (case-insensitive, partial match)."
    ),
    q: Optional[str] = Query(
        None, min_length=1, description="Search query for city name (case-insensitive, partial match)."
    ) # Search term
) -> Any:
    """
    Searches for cities based on query parameters.

    - Use the **q** parameter to search by city name.
    - Use the **country** parameter to filter by country.
    - Supports **pagination** using `limit` and `offset`.
    - Returns existing cached images only; does not trigger new image fetches.
    """
    cities = await crud.crud_city.search_cities(
        db=db,
        q=q,
        country_name=country,
        skip=offset,
        limit=limit
    )
    # FastAPI handles validation against List[CitySchema]
    return cities