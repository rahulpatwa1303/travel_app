# app/db/models/place.py
from sqlalchemy import (
    Column, Integer, String, Float, Text, DateTime, func, Index, ForeignKey, Boolean
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship  # Ensure relationship is imported
from app.db.base_class import Base
from sqlalchemy.dialects.postgresql import TSVECTOR
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .user import User # Import for type hinting


class Place(Base):
    __tablename__ = "places"

    id = Column(Integer, primary_key=True, index=True)

    # --- Foreign Key to City ---
    # Assuming a place *can* optionally belong to a city (nullable=True)
    # Change nullable=False if every place MUST belong to a city.
    city_id = Column(Integer, ForeignKey("cities.id"), nullable=True, index=True) # Added index=True

    # --- Core Place Attributes ---
    name = Column(String(255), nullable=False, index=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    category = Column(String(100), nullable=False, index=True)
    osm_id = Column(String(50), index=True, nullable=True)
    osm_type = Column(String(10), nullable=True)
    website = Column(Text, nullable=True)
    description = Column(Text, nullable=True)
    address = Column(Text, nullable=True)
    phone = Column(String(50), nullable=True)
    opening_hours = Column(Text, nullable=True)
    cuisine = Column(String(255), nullable=True)
    entry_fee = Column(String(100), nullable=True)
    religion = Column(String(100), nullable=True)
    denomination = Column(String(100), nullable=True)
    attributes = Column(JSONB, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    fts_vector = Column(TSVECTOR, index=True)

    favorited_by_users = relationship(
        "User",
        secondary="user_favorites", # Name of the association table
        back_populates="favorite_places" # Matches relationship name on User model
    )

    # --- Relationships ---

    # Relationship to City model (Many Places to One City)
    # 'back_populates' links this to the 'places' attribute in the City model
    city = relationship("City", back_populates="places")

    # Relationship to PlaceImage model (One Place to Many Images)
    # 'back_populates' links this to the 'place' attribute in PlaceImage model
    images = relationship("PlaceImage", back_populates="place", cascade="all, delete-orphan", lazy="selectin") # lazy="selectin" is often good for async

    # --- Table Args (Indexes) ---
    __table_args__ = (
         # Removed duplicate indexes if defined on columns directly
         Index('ix_places_location', 'latitude', 'longitude'),
         # Add other multi-column or functional indexes here if needed
     )