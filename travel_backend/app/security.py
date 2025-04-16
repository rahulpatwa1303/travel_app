# app/security.py
import logging
from datetime import datetime, timedelta
from typing import Optional, Any

from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import ValidationError
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

import asyncpg
from app.database import get_db_connection
from app.config import settings
from app.models import TokenData, User, UserInDB # Import User model for return type
# Import user fetching function from crud (will create below)
from app.crud import get_user_by_email

logger = logging.getLogger(__name__)

# --- Configuration ---
# Add these to your .env and app/config.py if you haven't already
# Example values - GENERATE YOUR OWN STRONG SECRET KEY
JWT_SECRET_KEY = settings.jwt_secret_key # Load from config
ALGORITHM = settings.jwt_algorithm # Load from config
ACCESS_TOKEN_EXPIRE_MINUTES = settings.access_token_expire_minutes # Load from config
REFRESH_TOKEN_EXPIRE_DAYS = settings.refresh_token_expire_days # New

# --- Password Hashing ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hashes a plain password."""
    return pwd_context.hash(password)

# --- OAuth2 Dependency ---
# Tells FastAPI where to look for the token (Authorization: Bearer <token>)
# tokenUrl should point to your login endpoint (we'll create this router soon)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login") # Adjusted tokenUrl path

# --- Dependency to Get Current User (No changes needed here) ---

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    # Inject the connection directly
    conn: asyncpg.Connection = Depends(get_db_connection)
) -> User:
    """ Dependency to verify JWT and return current user. """
    credentials_exception = HTTPException(...) # Keep definition
    user_db: Optional[UserInDB] = None

    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        email: Optional[str] = payload.get("sub")
        if email is None: raise credentials_exception
        # token_data = TokenData(email=email) # Not strictly needed if only using email

        # *** Use conn directly - NO 'async with' ***
        user_db = await get_user_by_email(conn=conn, email=email)

    except JWTError as e: logger.error(...); raise credentials_exception from e
    except ValidationError as e: logger.error(...); raise credentials_exception from e
    except HTTPException: raise # Re-raise HTTP exceptions from get_db_connection
    except Exception as e:
        logger.exception(f"Error during user retrieval/DB handling in get_current_user: {e}")
        raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, "Error processing authentication")

    if user_db is None:
        logger.warning(f"User specified in access token not found: {email}")
        raise credentials_exception

    try:
        return User.from_orm(user_db)
    except Exception as e:
         logger.exception(...); raise HTTPException(...)

async def get_current_active_user(current_user: User = Depends(get_current_user)) -> User:
    """ Ensures the fetched user is active. """
    if not current_user.is_active:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Inactive user")
    return current_user


# Dependency for optional authentication
async def get_optional_current_user(
    token: Optional[str] = Depends(oauth2_scheme) # Make token optional
) -> Optional[User]:
    if token is None:
        return None
    try:
        # Reuse get_current_user logic but handle exceptions locally
        return await get_current_user(token)
    except HTTPException:
        return None # Return None if token is invalid/expired or user not found
    

def create_jwt_token(data: dict, expires_delta: timedelta) -> tuple[str, datetime]:
    """Creates a JWT token with a specific expiry delta. Returns token and expiry time."""
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    # Consider adding 'iat' (issued at) and 'jti' (JWT ID) for more robust handling/revocation
    # to_encode.update({"iat": datetime.utcnow(), "jti": str(uuid.uuid4())})
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt, expire

def create_access_token(data: dict) -> tuple[str, datetime]:
    """Creates a short-lived access token."""
    expires_delta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    return create_jwt_token(data, expires_delta)

def create_refresh_token(data: dict) -> tuple[str, datetime]:
    """Creates a longer-lived refresh token."""
    expires_delta = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    # Ensure refresh token payload is minimal (e.g., only subject/user identifier)
    refresh_data = {"sub": data.get("sub")} # Only include subject
    return create_jwt_token(refresh_data, expires_delta)

def decode_token_payload(token: str) -> Optional[dict]:
    """Decodes JWT payload without verifying signature/expiry initially (useful for getting user)."""
    try:
        # Decode without verification first to potentially get user identifier
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM], options={"verify_signature": False, "verify_exp": False})
        return payload
    except JWTError as e:
        logger.error(f"Error decoding token payload: {e}")
        return None