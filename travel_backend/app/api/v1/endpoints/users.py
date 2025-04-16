# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException, status, Query, Path
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Any
from datetime import datetime, timedelta

from app import crud, schemas # Import models for current_user type hint
from app.db.models.user import User # Import User model
from app.api import deps
from app.core.config import settings # For pagination defaults
from app.schemas import Place as PlaceSchema # Use Place schema for favorites list
from app.schemas import VisitHistoryEntry # Use VisitHistoryEntry schema

router = APIRouter()

# --- Favorites Endpoints ---

@router.post(
    "/me/favorites/{place_id}",
    status_code=status.HTTP_201_CREATED, # Use 201 for successful creation
    summary="Favorite a Place",
    responses={
        status.HTTP_200_OK: {"description": "Place was already favorited"},
        status.HTTP_404_NOT_FOUND: {"description": "Place not found"},
    },
    # No response body needed on successful creation/existing
)
async def favorite_place(
    *,
    db: AsyncSession = Depends(deps.get_db),
    place_id: int = Path(..., title="The ID of the place to favorite", ge=1),
    current_user: User = Depends(deps.get_current_active_user),
) -> None:
    """Marks a place as a favorite for the current logged-in user."""
    favorite = await crud.crud_user_activity.add_favorite(db=db, user_id=current_user.id, place_id=place_id)
    if favorite is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Place not found")
    # Decide on status code: 201 if newly created, maybe 200 if already existed?
    # Simple approach: return 201 or 200 based on whether it was new.
    # However, returning None simplifies - let's stick to 201/200 logic implicit in add_favorite
    # If we return the favorite object, check if created_at is recent? Complex.
    # Let's just return None/204 on success for simplicity now.
    # Reverting to 204 NO CONTENT might be simplest RESTful approach for idempotency.
    # Let's try 200 OK - easier for client to handle than 201 vs 200 based on state.
    # --- Let's retry with 200 OK always on success ---
    return # FastAPI handles 200 OK with None body by default


@router.delete(
    "/me/favorites/{place_id}",
    status_code=status.HTTP_204_NO_CONTENT, # Standard for successful DELETE
    summary="Unfavorite a Place",
    responses={
        status.HTTP_404_NOT_FOUND: {"description": "Place not found or not favorited by user"},
    }
)
async def unfavorite_place(
    *,
    db: AsyncSession = Depends(deps.get_db),
    place_id: int = Path(..., title="The ID of the place to unfavorite", ge=1),
    current_user: User = Depends(deps.get_current_active_user),
) -> None:
    """Removes a place from the current user's favorites."""
    removed = await crud.crud_user_activity.remove_favorite(db=db, user_id=current_user.id, place_id=place_id)
    if not removed:
        # Raise 404 if place doesn't exist OR it wasn't favorited
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Place not found or not favorited")
    return None # Return None for 204 response


@router.get(
    "/me/favorites",
    response_model=List[PlaceSchema], # Returns list of Place objects
    summary="Get Favorite Places"
)
async def read_favorite_places(
    *,
    db: AsyncSession = Depends(deps.get_db),
    limit: int = Query(100, ge=1, le=200, description="Maximum number of favorites to return."),
    offset: int = Query(0, ge=0, description="Number of favorites to skip."),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """Retrieves the list of places favorited by the current user."""
    places = await crud.crud_user_activity.get_favorite_places(
        db=db, user_id=current_user.id, skip=offset, limit=limit
    )
    # The returned places objects need to be converted to schema,
    # including mapping image URLs correctly.
    # Let's adjust CRUD to return dicts or ensure schema conversion handles images.
    # --- Assuming Pydantic handles the Place model with its images relationship ---
    return places


@router.get(
    "/me/favorites/ids",
    response_model=List[int], # Returns list of integers (place IDs)
    summary="Get Favorite Place IDs"
)
async def read_favorite_place_ids(
    *,
    db: AsyncSession = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """Retrieves only the IDs of places favorited by the current user."""
    ids = await crud.crud_user_activity.get_favorite_place_ids(db=db, user_id=current_user.id)
    return ids


# --- Visit History Endpoints ---

@router.post(
    "/me/history/{place_id}",
    status_code=status.HTTP_201_CREATED,
    summary="Record Place Visit",
     responses={
        status.HTTP_404_NOT_FOUND: {"description": "Place not found"},
    },
    # Consider returning the created history entry? Or just 201? Let's return None.
)
async def record_place_visit(
    *,
    db: AsyncSession = Depends(deps.get_db),
    place_id: int = Path(..., title="The ID of the place visited", ge=1),
    current_user: User = Depends(deps.get_current_active_user),
) -> None:
    """Records that the current user has visited the specified place."""
    try:
        await crud.crud_user_activity.record_visit(db=db, user_id=current_user.id, place_id=place_id)
    except ValueError as e: # Catch specific error if place DNE from CRUD
         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    return None


@router.get(
    "/me/history",
    response_model=List[VisitHistoryEntry], # Use the specific history schema
    summary="Get Visit History"
)
async def read_visit_history(
    *,
    db: AsyncSession = Depends(deps.get_db),
    days: int = Query(30, ge=1, le=365, description="Number of past days of history to retrieve."),
    limit: int = Query(100, ge=1, le=200, description="Maximum number of history entries to return."),
    offset: int = Query(0, ge=0, description="Number of history entries to skip."),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """Retrieves the current user's place visit history for the last X days."""
    history_entries = await crud.crud_user_activity.get_visit_history(
        db=db, user_id=current_user.id, days=days, skip=offset, limit=limit
    )
    # The history_entries are UserVisitHistory objects with Place eager loaded.
    # Pydantic needs to convert these to the VisitHistoryEntry schema.
    # Ensure the relationships and orm_mode=True are set correctly.
    return history_entries