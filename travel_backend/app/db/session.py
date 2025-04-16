from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
import asyncpg # Ensure asyncpg is imported if needed for specific error handling

# Create async engine
engine = create_async_engine(settings.DATABASE_URL, pool_pre_ping=True, echo=False) # echo=True for debugging SQL

# Create async session maker
# expire_on_commit=False prevents detached instance errors after commit in async context
AsyncSessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db() -> AsyncSession:
    """
    Dependency function that yields an async SQLAlchemy session.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit() # Commit changes if no exceptions occurred
        except Exception:
            await session.rollback() # Rollback in case of errors
            raise
        finally:
            await session.close() # Ensure session is closed