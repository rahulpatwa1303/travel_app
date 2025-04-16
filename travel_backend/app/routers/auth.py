# app/routers/auth.py
import logging
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

import asyncpg
from app.database import get_db_connection
from app.models import RefreshTokenRequest, User, UserCreate, Token # Import necessary models
from app.crud import create_user, get_user_by_email # Import user CRUD
from app.security import create_access_token, get_current_active_user, ACCESS_TOKEN_EXPIRE_MINUTES # Import auth utils
from app.crud import (create_user, get_user_by_email, authenticate_user,
                    create_refresh_token_db, get_refresh_token_db, revoke_refresh_token_db, delete_refresh_token_db)
# ... (keep security imports: create_access_token, get_current_active_user, ACCESS_TOKEN_EXPIRE_MINUTES) ...
# ... (ADD create_refresh_token, decode_token_payload) ...
from app.security import (create_access_token, create_refresh_token, decode_token_payload,
                        get_current_active_user, ACCESS_TOKEN_EXPIRE_MINUTES)

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

@router.post("/register", response_model=User, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_in: UserCreate,
    db_conn_manager = Depends(get_db_connection)
):
    # ... (existing implementation) ...
    async with db_conn_manager as conn:
        existing_user = await get_user_by_email(conn=conn, email=user_in.email)
        if existing_user:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
        db_user = await create_user(conn=conn, user=user_in)
        if not db_user:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Could not create user.")
        return User.from_orm(db_user)


# --- MODIFIED /login endpoint ---
@router.post("/login", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db_conn_manager = Depends(get_db_connection)
):
    """Authenticate user and return JWT access and refresh tokens."""
    async with db_conn_manager as conn:
        user = await authenticate_user(conn=conn, email=form_data.username, password=form_data.password)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Create Access Token
        access_token_str, access_token_expires = create_access_token(
            data={"sub": user.email} # 'sub' is standard for subject (user identifier)
        )

        # Create Refresh Token
        refresh_token_str, refresh_token_expires = create_refresh_token(
            data={"sub": user.email} # Keep refresh token payload minimal
        )

        # Store Refresh Token in DB
        stored = await create_refresh_token_db(
            conn=conn,
            user_id=user.id,
            token=refresh_token_str,
            expires_at=refresh_token_expires
        )
        if not stored:
            # Handle potential DB error during refresh token storage
            logger.error(f"Failed to store refresh token for user {user.email}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Could not process login (token storage failed).",
            )

        # Commit transaction before returning tokens
        # Note: create_refresh_token_db doesn't commit implicitly
        # Depending on overall transaction strategy, commit might happen elsewhere
        # Adding explicit commit here for clarity after successful storage
        await conn.execute('COMMIT') # Or handle transactions at a higher level

    return {
        "access_token": access_token_str,
        "refresh_token": refresh_token_str, # Return refresh token
        "token_type": "bearer"
    }

# --- NEW /refresh endpoint ---
@router.post("/refresh", response_model=Token)
async def refresh_access_token(
    refresh_request: RefreshTokenRequest, # Get refresh token from request body
    db_conn_manager = Depends(get_db_connection)
):
    """Provides a new access and refresh token using a valid refresh token."""
    refresh_token_str = refresh_request.refresh_token
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials (refresh token)",
        headers={"WWW-Authenticate": "Bearer"},
    )

    async with db_conn_manager as conn:
        # 1. Find the token in the DB
        token_record = await get_refresh_token_db(conn, refresh_token_str)

        if not token_record:
            logger.warning("Refresh token not found in DB.")
            raise credentials_exception
        if token_record['revoked_at'] is not None:
             logger.warning(f"Attempted to use revoked refresh token ID: {token_record['id']}")
             # Optionally delete the token here: await delete_refresh_token_db(conn, token_record['id'])
             raise credentials_exception
        if token_record['expires_at'] < datetime.utcnow().replace(tzinfo=None): # Compare naive UTC time
             logger.warning(f"Attempted to use expired refresh token ID: {token_record['id']}")
             # Optionally delete the token here: await delete_refresh_token_db(conn, token_record['id'])
             raise credentials_exception

        # 2. Decode payload to get user identifier (no strict verify needed here, DB check is primary)
        payload = decode_token_payload(refresh_token_str)
        if not payload or not payload.get("sub"):
             logger.error(f"Could not decode refresh token payload or missing 'sub': ID {token_record['id']}")
             # Revoke potentially compromised token?
             await revoke_refresh_token_db(conn, token_record['id'])
             await conn.execute('COMMIT')
             raise credentials_exception

        email = payload.get("sub")

        # 3. Verify token belongs to a valid user
        user = await get_user_by_email(conn, email)
        if not user or user.id != token_record['user_id'] or not user.is_active:
             logger.error(f"Refresh token user mismatch or inactive user. Token User: {email}, DB User ID: {token_record['user_id']}")
             # Revoke the token
             await revoke_refresh_token_db(conn, token_record['id'])
             await conn.execute('COMMIT')
             raise credentials_exception

        # --- Refresh Token Rotation (Recommended) ---
        # 4. Revoke the used refresh token
        revoked = await revoke_refresh_token_db(conn, token_record['id'])
        if not revoked:
             logger.error(f"Failed to revoke used refresh token ID: {token_record['id']}")
             # Decide whether to proceed or raise error - proceeding might be okay if already revoked
             # raise HTTPException(status_code=500, detail="Token revocation failed.")

        # 5. Issue new tokens
        new_access_token_str, _ = create_access_token(data={"sub": user.email})
        new_refresh_token_str, new_refresh_expires = create_refresh_token(data={"sub": user.email})

        # 6. Store the *new* refresh token
        stored = await create_refresh_token_db(
            conn=conn,
            user_id=user.id,
            token=new_refresh_token_str,
            expires_at=new_refresh_expires
        )
        if not stored:
             logger.error(f"Failed to store NEW refresh token for user {user.email} during refresh.")
             # Critical failure - user might be logged out unexpectedly
             await conn.execute('ROLLBACK') # Rollback revocation if storage fails
             raise HTTPException(status_code=500, detail="Could not process token refresh.")

        # Commit transaction
        await conn.execute('COMMIT')

    return {
        "access_token": new_access_token_str,
        "refresh_token": new_refresh_token_str, # Return the *new* refresh token
        "token_type": "bearer"
    }

# --- NEW /logout endpoint (Optional but Recommended) ---
@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(
    refresh_request: RefreshTokenRequest, # Requires client to send the refresh token to revoke
    db_conn_manager = Depends(get_db_connection),
    # Optional: Require access token to prove identity? Depends on security model.
    # current_user: User = Depends(get_current_active_user)
):
    """Revokes the provided refresh token, effectively logging the user out for that token."""
    refresh_token_str = refresh_request.refresh_token
    async with db_conn_manager as conn:
        token_record = await get_refresh_token_db(conn, refresh_token_str)
        if token_record:
             # Optional: Verify token belongs to current_user if authentication is added
             # if current_user and token_record['user_id'] != current_user.id:
             #     raise HTTPException(status_code=403, detail="Cannot revoke token for another user")
             revoked = await revoke_refresh_token_db(conn, token_record['id'])
             if revoked:
                 await conn.execute('COMMIT')
                 logger.info(f"User logged out by revoking refresh token ID: {token_record['id']}")
                 return # Return 204 No Content on success
             else:
                 # Already revoked or DB error
                  logger.warning(f"Logout failed or token already invalid for refresh token ID: {token_record['id']}")
                  # Still return success-like code as client goal (logout) is achieved if token invalid
                  return
        else:
            # Token not found - treat as logged out
            logger.warning("Logout attempt with non-existent refresh token.")
            return # Return 204 No Content

# --- (Keep /users/me endpoint as is) ---
@router.get("/users/me", response_model=User)
async def read_users_me(
    current_user: User = Depends(get_current_active_user) # Use dependency here
):
    """Get the profile of the currently authenticated user."""
    return current_user