# app/crud/crud_user_activity.py
import logging
from typing import List, Optional
from datetime import datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, and_
from sqlalchemy.orm import selectinload, joinedload

from app.db import models
from app.schemas import Place as PlaceSchema # For returning favorite places

logger = logging.getLogger(__name__)

# --- Favorite Operations ---

async def add_favorite(db: AsyncSession, *, user_id: int, place_id: int) -> Optional[models.UserFavorite]:
    """Adds a place to user's favorites. Returns the association object or None if place DNE."""
    # Optional: Check if place exists first
    place = await db.get(models.Place, place_id)
    if not place:
        logger.warning(f"Attempt to favorite non-existent place {place_id} by user {user_id}")
        return None # Indicate place not found

    # Check if already favorited
    stmt_check = select(models.UserFavorite).where(
        models.UserFavorite.user_id == user_id,
        models.UserFavorite.place_id == place_id
    )
    existing_favorite = await db.execute(stmt_check)
    if existing_favorite.scalars().first():
        logger.info(f"Place {place_id} already favorited by user {user_id}")
        # Return existing record or just True/None to indicate success
        return existing_favorite.scalars().first()

    # Create new favorite record
    db_fav = models.UserFavorite(user_id=user_id, place_id=place_id)
    db.add(db_fav)
    # Commit will be handled by the request lifecycle (get_db dependency)
    # await db.flush() # Optional: Flush to ensure it exists before returning (no ID needed here)
    logger.info(f"Added place {place_id} to favorites for user {user_id}")
    return db_fav


async def remove_favorite(db: AsyncSession, *, user_id: int, place_id: int) -> bool:
    """Removes a place from user's favorites. Returns True if removed, False otherwise."""
     # Optional: Check if place exists (for accurate logging/feedback)
    place = await db.get(models.Place, place_id)
    if not place:
        logger.warning(f"Attempt to unfavorite non-existent place {place_id} by user {user_id}")
        return False # Indicate place not found

    stmt = delete(models.UserFavorite).where(
        models.UserFavorite.user_id == user_id,
        models.UserFavorite.place_id == place_id
    ).returning(models.UserFavorite.user_id) # Use returning to check if a row was actually deleted

    result = await db.execute(stmt)
    # Commit handled by request lifecycle
    if result.scalar_one_or_none() is not None:
         logger.info(f"Removed place {place_id} from favorites for user {user_id}")
         return True
    else:
        logger.warning(f"Attempt to unfavorite place {place_id} not favorited by user {user_id}")
        return False # Indicate it wasn't favorited


async def get_favorite_places(db: AsyncSession, *, user_id: int, skip: int = 0, limit: int = 100) -> List[models.Place]:
    """Gets the list of places favorited by a user."""
    stmt = (
        select(models.Place)
        .join(models.UserFavorite, models.Place.id == models.UserFavorite.place_id)
        .where(models.UserFavorite.user_id == user_id)
        .order_by(models.UserFavorite.created_at.desc()) # Order by when favorited
        .options(selectinload(models.Place.images).load_only(models.PlaceImage.image_url)) # Eager load image URLs
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(stmt)
    places = result.scalars().all()
    return places


async def get_favorite_place_ids(db: AsyncSession, *, user_id: int) -> List[int]:
    """Gets only the IDs of places favorited by a user."""
    stmt = select(models.UserFavorite.place_id).where(models.UserFavorite.user_id == user_id)
    result = await db.execute(stmt)
    ids = result.scalars().all()
    return ids


# --- Visit History Operations ---

async def record_visit(db: AsyncSession, *, user_id: int, place_id: int) -> models.UserVisitHistory:
    """Records a user visiting a place."""
    # Optional: Check if place exists
    place = await db.get(models.Place, place_id)
    if not place:
         # Decide how to handle: raise error, return None, or log and proceed?
         # Raising might be cleaner if the calling endpoint expects the place to exist.
         logger.error(f"Attempt to record visit for non-existent place {place_id} by user {user_id}")
         raise ValueError(f"Place with id {place_id} not found.") # Example: Raise error

    db_visit = models.UserVisitHistory(user_id=user_id, place_id=place_id)
    db.add(db_visit)
    # Commit handled by request lifecycle
    logger.info(f"Recorded visit for user {user_id} to place {place_id}")
    return db_visit


async def get_visit_history(db: AsyncSession, *, user_id: int, days: int = 30, skip: int = 0, limit: int = 100) -> List[models.UserVisitHistory]:
    """Gets the user's visit history for the specified number of past days."""
    since_date = datetime.utcnow() - timedelta(days=days)

    stmt = (
        select(models.UserVisitHistory)
        .where(
            models.UserVisitHistory.user_id == user_id,
            models.UserVisitHistory.visited_at >= since_date
        )
        .order_by(models.UserVisitHistory.visited_at.desc())
        # Eager load the related Place object and its image URLs
        .options(
            joinedload(models.UserVisitHistory.place) # Use joinedload for Place
            .selectinload(models.Place.images) # Then selectinload for images from Place
            .load_only(models.PlaceImage.image_url) # Only load the image URL
        )
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(stmt)
    # Need unique() because joinedload can cause duplicates if multiple history entries point to same place
    history_entries = result.scalars().unique().all()
    return history_entries