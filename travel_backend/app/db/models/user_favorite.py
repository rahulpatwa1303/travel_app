# app/db/models/user_favorite.py
from sqlalchemy import Column, Integer, DateTime, func, ForeignKey, PrimaryKeyConstraint
from app.db.base_class import Base

class UserFavorite(Base):
    __tablename__ = "user_favorites"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    place_id = Column(Integer, ForeignKey("places.id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Define composite primary key constraint if not using primary_key=True on columns
    # __table_args__ = (PrimaryKeyConstraint('user_id', 'place_id'),)

    # Relationships are usually defined on the 'main' models (User, Place)