# app/config.py
import os
from pydantic import BaseSettings, Field
from dotenv import load_dotenv # <-- Import load_dotenv

# --- Load .env file explicitly ---
# Determine the path to the .env file relative to this config file or project root
# This assumes .env is in the project root, one level up from the 'app' directory
dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
# Alternative if config.py is directly in project root:
# dotenv_path = os.path.join(os.path.dirname(__file__), '.env')

load_dotenv(dotenv_path=dotenv_path, verbose=True) # verbose=True logs what's loaded
# ---------------------------------

class Settings(BaseSettings):
    database_url: str = Field(..., env='DATABASE_URL')
    default_page_size: int = Field(20, env='DEFAULT_PAGE_SIZE')
    max_page_size: int = Field(100, env='MAX_PAGE_SIZE')

    jwt_secret_key: str = Field(..., env='JWT_SECRET_KEY')
    jwt_algorithm: str = Field("HS256", env='JWT_ALGORITHM')
    # Keep defaults here as fallbacks, but env var should override
    access_token_expire_minutes: int = Field(30, env='ACCESS_TOKEN_EXPIRE_MINUTES')
    refresh_token_expire_days: int = Field(7, env='REFRESH_TOKEN_EXPIRE_DAYS')

    # REMOVED class Config: Pydantic v1 BaseSettings finds .env automatically,
    # but explicit load_dotenv above is more robust for troubleshooting.
    # If using Pydantic v2, you might need the Config class back.
    # For Pydantic v1, explicit load_dotenv is usually sufficient.

settings = Settings()

# Optional: Print loaded value for debugging after Settings() is called
print(f"DEBUG: Loaded ACCESS_TOKEN_EXPIRE_MINUTES = {settings.access_token_expire_minutes} (Type: {type(settings.access_token_expire_minutes)})")