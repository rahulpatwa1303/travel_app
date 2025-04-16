# main.py
import logging
from fastapi import FastAPI, status
from contextlib import asynccontextmanager

from app.database import connect_to_db, close_db_connection
from app.routers import auth, places, users # Import your places router

# Configure logging format
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(module)s - %(message)s')
logger = logging.getLogger(__name__)

# Lifespan context manager for startup/shutdown events
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Application startup...")
    await connect_to_db() # Initialize DB pool
    yield
    # Shutdown
    logger.info("Application shutdown...")
    await close_db_connection() # Close DB pool

app = FastAPI(
    title="Places API",
    description="API to query information about landmarks, natural wonders, and restaurants.",
    version="0.1.0",
    lifespan=lifespan # Use the lifespan context manager
)

# Include routers
app.include_router(places.router)
app.include_router(auth.router)
app.include_router(users.router)

# Root endpoint
@app.get("/", tags=["Root"], status_code=status.HTTP_200_OK)
async def read_root():
    """Root endpoint providing basic API info."""
    return {"message": "Welcome to the Places API!"}

# Optional: Add custom exception handlers here if needed

# To run the app (from the project root directory):
# uvicorn main:app --reload --host 0.0.0.0 --port 8000