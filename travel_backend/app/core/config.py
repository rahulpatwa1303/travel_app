import os
from pydantic import BaseSettings, AnyHttpUrl, EmailStr, validator
from typing import List, Optional
from dotenv import load_dotenv

# Load .env file variables
load_dotenv()

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "FastAPI SM Backend"

    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:pass@host:port/db")

    # JWT Settings
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "default_secret_key")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    REFRESH_TOKEN_EXPIRE_DAYS: int = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))

    # Pagination (Optional, using defaults from .env)
    DEFAULT_PAGE_SIZE: int = int(os.getenv("DEFAULT_PAGE_SIZE", 20))
    MAX_PAGE_SIZE: int = int(os.getenv("MAX_PAGE_SIZE", 100))
    OWM_API_KEY: str = os.getenv("OWM_API_KEY","8e5718c568f5a5c51c81c827f7bd17bf")
    # Example of how to add CORS origins if needed later
    # BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []
    # @validator("BACKEND_CORS_ORIGINS", pre=True)
    # def assemble_cors_origins(cls, v: str | List[str]) -> List[str] | str:
    #     if isinstance(v, str) and not v.startswith("["):
    #         return [i.strip() for i in v.split(",")]
    #     elif isinstance(v, (list, str)):
    #         return v
    #     raise ValueError(v)

    class Config:
        case_sensitive = True
        # If you are using Pydantic V2, use model_config instead of Config class
        # model_config = SettingsConfigDict(case_sensitive=True, env_file=".env", extra="ignore")


settings = Settings()

# Ensure JWT_SECRET_KEY is set, raise error if not (important for security)
if settings.JWT_SECRET_KEY == "default_secret_key":
    print("WARNING: JWT_SECRET_KEY is using the default value. Please set a strong secret key in your .env file.")
    # Consider raising an exception in production:
    # raise ValueError("JWT_SECRET_KEY must be set in the environment variables.")