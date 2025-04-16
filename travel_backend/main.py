from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware # If you need CORS later

from app.core.config import settings
from app.api.v1.endpoints import auth, cities, places, users # Import your auth router

# Initialize FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json" # Set OpenAPI URL under API version
)

# --- Middlewares ---
# Set all CORS enabled origins - adjust in production!
# Example: Allow all origins (use with caution)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Or specify ["http://localhost:3000", "https://yourfrontend.com"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Add other middlewares here if needed (e.g., logging, timing)


# --- Routers ---
app.include_router(auth.router, prefix=settings.API_V1_STR + "/auth", tags=["Authentication"])
app.include_router(cities.router, prefix=settings.API_V1_STR + "/cities", tags=["Cities"]) 
# Add other routers here later (e.g., places)
app.include_router(places.router, prefix=settings.API_V1_STR + "/places", tags=["Places"])
app.include_router(users.router, prefix=settings.API_V1_STR + "/users", tags=["Users"]) # 

# --- Root Endpoint ---
@app.get("/", tags=["Root"])
async def read_root():
    return {"message": f"Welcome to {settings.PROJECT_NAME}"}

# --- Lifespan Events (Optional) ---
# Example: Connect/disconnect database pool (though sessionmaker handles much of this)
# @app.on_event("startup")
# async def startup_event():
#     # Initialize database connections etc.
#     pass

# @app.on_event("shutdown")
# async def shutdown_event():
#     # Clean up resources
#     pass

# --- Uvicorn Entry Point (for running with `python app/main.py`) ---
# Usually, you run with `uvicorn app.main:app --reload`
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) # Adjust host/port as needed