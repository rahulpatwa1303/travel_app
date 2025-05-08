# app/db/models/user_favorite_city.py
from sqlalchemy import Column, Integer, DateTime, func, ForeignKey, PrimaryKeyConstraint
from app.db.base_class import Base

class UserFavoriteCity(Base):
    __tablename__ = "user_favorite_cities"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    city_id = Column(Integer, ForeignKey("cities.id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships defined on User and City models