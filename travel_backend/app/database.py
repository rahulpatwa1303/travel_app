# app/database.py
import asyncpg
import logging
from contextlib import asynccontextmanager
import asyncio
from typing import Optional, AsyncGenerator
from app.config import settings

logger = logging.getLogger(__name__)

db_pool: Optional[asyncpg.Pool] = None

async def connect_to_db():
    global db_pool
    if db_pool is not None:
        logger.info("Database pool already initialized.")
        return
    logger.info(f"Connecting to database: {settings.database_url}")
    try:
        db_pool = await asyncpg.create_pool(
            dsn=settings.database_url,
            min_size=5,
            max_size=20,
            command_timeout=60,
            timeout=15 # Slightly longer connection timeout for startup
        )
        logger.info("Database connection pool established.")
        # Test connection
        async with db_pool.acquire(timeout=10) as connection: # Add timeout here too
            val = await connection.fetchval('SELECT 1')
            if val == 1:
                logger.info("Database connection test successful.")
            else:
                logger.warning("Database connection test returned unexpected value.")
    except Exception as e:
        logger.exception(f"FATAL: Could not connect to database during startup: {e}")
        db_pool = None

async def close_db_connection():
    global db_pool
    if db_pool:
        logger.info("Closing database connection pool...")
        try:
             await asyncio.wait_for(db_pool.close(), timeout=10.0)
             logger.info("Database connection pool closed.")
        except Exception as e:
             logger.exception(f"Error closing database pool: {e}")
        finally:
             db_pool = None

@asynccontextmanager
async def get_db_connection() -> AsyncGenerator[asyncpg.Connection, None]:
    """ Provides a database connection from the pool using async context manager. """
    t1 = asyncio.get_event_loop().time()
    logger.debug("Acquiring DB connection...")
    if db_pool is None:
        logger.error("DB pool is not initialized.")
        raise RuntimeError("Database pool is not initialized.")
    if db_pool.is_closing():
        logger.error("DB pool is closing.")
        raise RuntimeError("Database connection pool is closing.")

    conn: asyncpg.Connection | None = None # Use | None for Python 3.10+
    try:
        # Acquire using the pool's context manager for robust release
        async with db_pool.acquire(timeout=10) as conn: # Use context manager here
            t2 = asyncio.get_event_loop().time()
            logger.debug(f"DB connection {id(conn)} acquired in {t2-t1:.4f}s. Yielding...")
            yield conn # Yield the connection
            t3 = asyncio.get_event_loop().time()
            logger.debug(f"DB connection {id(conn)} yield finished. Time in use: {t3-t2:.4f}s.")
        # conn is automatically released here by exiting the inner 'async with'
        logger.debug(f"DB connection {id(conn)} released back to pool.")
        conn = None # Clear ref after release
    except asyncio.TimeoutError:
         logger.error("Timeout acquiring database connection from pool.")
         raise RuntimeError("Timeout acquiring database connection.") from None
    except Exception as e:
        logger.exception(f"Error during DB connection lifecycle: {e}")
        # Re-raise potentially modified exception if needed, otherwise just raise original
        raise RuntimeError(f"Failed to get database connection: {e}") from e
    # No finally needed as acquire context manager handles release