from fastapi import APIRouter, BackgroundTasks, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Any

from app import crud, schemas # Import top-level crud and schemas
from app.api import deps # Import dependencies (like get_db)
from app.core.config import settings # Import settings for defaults
from app.schemas import City as CitySchema # Import and potentially alias

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