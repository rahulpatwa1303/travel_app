import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship # If you add relationships later
from app.db.base_class import Base
from typing import TYPE_CHECKING # For type hints without circular imports

if TYPE_CHECKING:
    from .user_favorite import UserFavorite # Import only for type hinting
    from .user_visit_history import UserVisitHistory
    from .place import Place # Import Place for favorite_places relationship


class User(Base):
    __tablename__ = "users" # Good practice to explicitly name the table

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, index=True, nullable=True) # Optional: Add more fields as needed
    is_active = Column(Boolean(), default=True)
    is_superuser = Column(Boolean(), default=False) # Optional: For admin roles
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    # Store the current valid refresh token (or its hash) for logout/invalidation purposes
    refresh_token = Column(String, nullable=True, index=True)

        # Relationship to UserVisitHistory (One User has Many History Entries)
    visit_history = relationship("UserVisitHistory", back_populates="user", cascade="all, delete-orphan")

    # Relationship to Place through the user_favorites association table
    # This provides direct access like current_user.favorite_places
    favorite_places = relationship(
        "Place",
        secondary="user_favorites", # Name of the association table
        back_populates="favorited_by_users" # Matches relationship name on Place model
        # lazy="selectin" # Strategy for loading favorite places
    )


    # Add relationships here if needed, e.g.:
    # places = relationship("Place", back_populates="owner")