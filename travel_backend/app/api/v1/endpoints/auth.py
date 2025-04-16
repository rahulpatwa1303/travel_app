from fastapi import APIRouter, Depends, HTTPException, status, Body
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Any

from app.schemas import user,token
from app.crud import crud_user
from app.api import deps
from app.core.config import settings
from app.services import security
from app.db.models.user import User # Import User model

router = APIRouter()

@router.post("/register", response_model=user.User, status_code=status.HTTP_201_CREATED)
async def register_user(
    *,
    db: AsyncSession = Depends(deps.get_db),
    user_in: user.UserCreate,
) -> Any:
    """
    Register a new user.
    """
    user = await crud_user.get_user_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The user with this email already exists in the system.",
        )
    user = await crud_user.create_user(db=db, user_in=user_in)
    return user


@router.post("/login", response_model=token.Token)
async def login_for_access_token(
    db: AsyncSession = Depends(deps.get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests.
    Username field is used for email.
    """
    user = await crud_user.authenticate_user(
        db, email=form_data.username, password=form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    elif not user.is_active:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user")

    access_token = security.create_access_token(subject=user.id)
    refresh_token = security.create_refresh_token(subject=user.id)

    # Store the new refresh token in the database
    await crud_user.update_refresh_token(db=db, user_id=user.id, refresh_token=refresh_token)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }


@router.post("/refresh", response_model=token.Token)
async def refresh_access_token(
    *,
    db: AsyncSession = Depends(deps.get_db),
    refresh_request: token.RefreshTokenRequest, # Get refresh token from body
) -> Any:
    """
    Refresh access token using a refresh token.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    token_data = security.decode_token(refresh_request.refresh_token)

    # Basic check if token is decodable and has subject
    if not token_data or token_data.sub is None:
         raise credentials_exception

    try:
        user_id = int(token_data.sub)
    except ValueError:
        raise credentials_exception # If sub is not a valid integer ID

    user = await crud_user.get_user(db, user_id=user_id)

    # Validate user exists and the provided refresh token matches the one stored
    if not user or not user.is_active or user.refresh_token != refresh_request.refresh_token:
        # If tokens don't match, or user not found/inactive, invalidate potentially compromised token
        if user:
            await crud_user.update_refresh_token(db=db, user_id=user.id, refresh_token=None)
        raise credentials_exception

    # Issue new tokens (Access and optionally Refresh - Token Rotation)
    new_access_token = security.create_access_token(subject=user.id)
    # Optional: Implement refresh token rotation for better security
    new_refresh_token = security.create_refresh_token(subject=user.id)
    await crud_user.update_refresh_token(db=db, user_id=user.id, refresh_token=new_refresh_token)

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token, # Return the new refresh token
        "token_type": "bearer",
    }


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(
    *,
    db: AsyncSession = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user), # Ensure user is logged in
) -> None:
    """
    Logout user by invalidating the stored refresh token.
    """
    if current_user:
        await crud_user.update_refresh_token(db=db, user_id=current_user.id, refresh_token=None)
    # No response body needed for 204
    return None


# Example protected route:
@router.get("/me", response_model=user.User)
async def read_users_me(
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current logged-in user.
    """
    return current_user