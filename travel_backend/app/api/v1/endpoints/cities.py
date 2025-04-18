from fastapi import APIRouter, BackgroundTasks, Depends, Path, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Any

from app import crud, schemas # Import top-level crud and schemas
from app.api import deps # Import dependencies (like get_db)
from app.core.config import settings # Import settings for defaults
from app.schemas import City as CitySchema # Import and potentially alias
from app.schemas import City as CityListSchema # Schema for list
from app.schemas import CityDetail as CityDetailSchema # Schema for detail


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
    city_details = await crud.crud_city.get_city_details(
        db=db, city_id=city_id, background_tasks=background_tasks
    )

    if not city_details:
        raise HTTPException(status_code=404, detail="City not found")

    # FastAPI validates the returned dict against CityDetailSchema
    return city_details