from typing import Any, Dict, Optional, Union

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import selectinload # If needed for relationships

from app.services.security import get_password_hash, verify_password
from app.db.models.user import User
from app.schemas.user import UserCreate, UserUpdate

async def get_user(db: AsyncSession, user_id: int) -> Optional[User]:
    """Gets a user by ID."""
    result = await db.execute(select(User).filter(User.id == user_id))
    return result.scalars().first()

async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
    """Gets a user by email."""
    result = await db.execute(select(User).filter(User.email == email))
    return result.scalars().first()

async def create_user(db: AsyncSession, *, user_in: UserCreate) -> User:
    """Creates a new user."""
    hashed_password = get_password_hash(user_in.password)
    db_user = User(
        email=user_in.email,
        hashed_password=hashed_password,
        full_name=user_in.full_name,
        is_superuser=user_in.is_superuser, # Ensure this is handled safely
    )
    db.add(db_user)
    await db.commit() # Commit to get the ID assigned
    await db.refresh(db_user) # Refresh to get default values like created_at
    return db_user

async def update_user(
    db: AsyncSession, *, db_user: User, user_in: Union[UserUpdate, Dict[str, Any]]
) -> User:
    """Updates an existing user."""
    if isinstance(user_in, dict):
        update_data = user_in
    else:
        update_data = user_in.dict(exclude_unset=True) # Use .model_dump for Pydantic V2

    if "password" in update_data and update_data["password"]:
        hashed_password = get_password_hash(update_data["password"])
        del update_data["password"] # Remove plain password from update data
        update_data["hashed_password"] = hashed_password

    # Update user fields
    for field, value in update_data.items():
         # Check if the attribute exists before setting to avoid errors
        if hasattr(db_user, field):
            setattr(db_user, field, value)

    db.add(db_user) # Add the updated object to the session
    await db.commit() # Commit changes
    await db.refresh(db_user) # Refresh to get any updated defaults/triggers
    return db_user


async def update_refresh_token(db: AsyncSession, *, user_id: int, refresh_token: Optional[str]) -> None:
    """Updates the refresh token for a user."""
    stmt = update(User).where(User.id == user_id).values(refresh_token=refresh_token)
    await db.execute(stmt)
    await db.commit() # Commit this specific change


async def authenticate_user(
    db: AsyncSession, email: str, password: str
) -> Optional[User]:
    """Authenticates a user."""
    user = await get_user_by_email(db, email=email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user