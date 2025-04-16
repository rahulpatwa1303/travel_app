# app/db/models/place_image.py
from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class PlaceImage(Base):
    __tablename__ = "place_images"

    id = Column(Integer, primary_key=True, index=True)
    place_id = Column(Integer, ForeignKey("places.id"), nullable=False, index=True)
    image_url = Column(String, nullable=False) # Use String if TEXT gives issues with some drivers/versions, else TEXT is fine
    source = Column(String(50), default="wikimedia", nullable=False)
    is_featured = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationship back to Place
    place = relationship("Place", back_populates="images")