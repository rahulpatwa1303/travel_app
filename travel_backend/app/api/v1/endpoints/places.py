# app/api/v1/endpoints/places.py
from enum import Enum
from fastapi import APIRouter, BackgroundTasks, Depends, Query, HTTPException, Path
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Any

from app import crud, schemas # Use top-level imports
from app.api import deps
from app.core.config import settings # For pagination defaults
from app.schemas import PlaceDetail as PlaceDetailSchema # Schema for detail
from app.schemas import Place as PlaceListSchema

router = APIRouter()

class PlaceSortOptions(str, Enum):
    relevance = "relevance"
    name_asc = "name_asc"
    name_desc = "name_desc"
    # Add more later e.g., distance_asc, rating_desc

# Keep /categories endpoint from before
@router.get(
    "/categories",
    response_model=List[str], # Expecting a list of strings
    summary="Get Place Categories",
    description="Retrieve a distinct list of all available place categories.",
)
async def read_place_categories(
    db: AsyncSession = Depends(deps.get_db),
) -> Any:
    """
    Fetches a sorted list of unique categories assigned to places
    in the database. Useful for populating filter options.
    """
    categories = await crud.crud_place.get_distinct_categories(db=db)
    return categories



@router.get(
    "/",
    response_model=List[PlaceListSchema],
    summary="Get Places (with Search, Filter, Sort)",
    description="Retrieve places with filtering, full-text search, sorting, and background image fetching."
)
async def read_places(
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(deps.get_db),
    limit: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    offset: int = Query(0, ge=0),
    city_id: Optional[int] = Query(None),
    category: Optional[str] = Query(None),
    q: Optional[str] = Query(None, description="Full-text search query across name, category, description."), # <<< Add q
    sort_by: Optional[PlaceSortOptions] = Query(PlaceSortOptions.name_asc, description="Sorting order for results.") # <<< Add sort_by
) -> Any:
    """
    Retrieves a list of places with filtering, search, and sorting.

    - Fetches existing images efficiently.
    - Triggers background tasks to fetch images from Wikimedia if missing.
    - Supports pagination (`limit`, `offset`), filtering (`city_id`, `category`),
      full-text search (`q`), and sorting (`sort_by`).
    """
    # Ensure sort_by relevance is only used if q is provided
    if sort_by == PlaceSortOptions.relevance and not q:
         sort_by = PlaceSortOptions.name_asc # Default if relevance requested without query

    places = await crud.crud_place.get_places(
        db=db,
        background_tasks=background_tasks,
        city_id=city_id,
        category=category,
        q=q, # Pass search query
        sort_by=sort_by.value if sort_by else None, # Pass sorting value
        skip=offset,
        limit=limit
    )
    return places

# --- NEW Endpoint for Place Details ---
@router.get(
    "/{place_id}", # Path parameter for the place ID
    response_model=PlaceDetailSchema, # Use the detailed schema
    summary="Get Place Details",
    description="Retrieve detailed information for a specific place by its ID.",
    responses={404: {"description": "Place not found"}} # Document the 404 error
)
async def read_place_detail(
    background_tasks: BackgroundTasks, # Inject for image fetching task
    # Use Path for path parameters, adding validation like greater-than-0
    place_id: int = Path(..., title="The ID of the place to retrieve", ge=1),
    db: AsyncSession = Depends(deps.get_db),
) -> Any:
    """
    Retrieves comprehensive details for a single place, including images.

    - Fetches existing images or triggers background fetching if needed.
    - Returns a 404 error if the place ID is not found.
    """
    place_details = await crud.crud_place.get_place_details_with_images(
        db=db, place_id=place_id, background_tasks=background_tasks
    )

    if not place_details:
        raise HTTPException(status_code=404, detail="Place not found")

    # The dictionary returned by the CRUD function will be validated
    # against the PlaceDetailSchema response_model by FastAPI.
    return place_details