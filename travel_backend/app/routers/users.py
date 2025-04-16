# app/routers/users.py
import logging
from fastapi import APIRouter, Depends, HTTPException, status, Body
from typing import List, Dict, Any

import asyncpg
from app.database import get_db_connection
from app.models import User, UserPreferencesUpdate # Import relevant models
from app.security import get_current_active_user # Import auth dependency
from app.crud import update_user_preferences_db, get_user_by_email # Import CRUD

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/users",
    tags=["Users"],
    dependencies=[Depends(get_current_active_user)] # Secure all user routes
)

# Get current user profile (moved from auth router for better organization)
@router.get("/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    """Get the profile of the currently authenticated user."""
    return current_user

# Get user preferences (Optional - can be added later)
# @router.get("/me/preferences", ...)

# --- *** ADD NEW ENDPOINT for Updating Preferences *** ---
@router.put("/me/preferences", status_code=status.HTTP_204_NO_CONTENT)
async def update_preferences_for_me(
    preferences_in: UserPreferencesUpdate, # Use the Pydantic model for request body
    conn: asyncpg.Connection = Depends(get_db_connection),
    current_user: User = Depends(get_current_active_user) # Ensure user is logged in
):
    """
    Update the preferences (e.g., interests) for the currently authenticated user.
    Expects a JSON body like: {"interests": ["hiking", "museums"]}
    """
    # Convert Pydantic model to dict to store in JSONB
    preferences_dict = preferences_in.dict()

    logger.info(f"Updating preferences for user {current_user.email} (ID: {current_user.id})")
    success = await update_user_preferences_db(
        conn=conn,
        user_id=current_user.id,
        preferences=preferences_dict # Store the whole object as JSONB for now
    )

    if not success:
        # update_user_preferences_db logs details
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not update user preferences."
        )

    # Return 204 No Content on success
    return None # FastAPI handles the 204 response when None is returned