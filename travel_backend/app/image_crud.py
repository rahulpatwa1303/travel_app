# crud/image_crud.py
import asyncpg
from typing import Optional, Tuple
import datetime

async def get_image_by_place(
    conn: asyncpg.Connection,
    place_table: str,
    place_id: int
) -> Optional[Tuple[str, str, datetime.datetime]]:
    """Fetches cached image URL, source, and fetch time by place."""
    query = """
        SELECT image_url, source, last_fetched_at
        FROM poi_images
        WHERE place_table = $1 AND place_id = $2
    """
    row = await conn.fetchrow(query, place_table, place_id)
    if row:
        # Optionally update last_fetched_at here if desired on every read
        # await conn.execute("UPDATE poi_images SET last_fetched_at = NOW() WHERE id = $1", row['id']) # Or pass ID if selected
        return row['image_url'], row['source'], row['last_fetched_at']
    return None

async def add_or_update_place_image(
    conn: asyncpg.Connection,
    place_table: str,
    place_id: int,
    image_url: Optional[str], # Can be None if not found
    source: str
) -> None:
    """Inserts a new image cache entry or updates an existing one."""
    query = """
        INSERT INTO poi_images (place_table, place_id, image_url, source, last_fetched_at)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (place_table, place_id) DO UPDATE SET
            image_url = EXCLUDED.image_url,
            source = EXCLUDED.source,
            last_fetched_at = NOW()
    """
    try:
        await conn.execute(query, place_table, place_id, image_url, source)
        logger.info(f"Cached image for {place_table} ID {place_id}. URL: {image_url}, Source: {source}")
    except Exception as e:
        logger.error(f"Failed to add/update poi_image for {place_table} ID {place_id}: {e}", exc_info=True)