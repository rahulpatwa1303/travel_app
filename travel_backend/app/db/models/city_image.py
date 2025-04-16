from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class CityImage(Base):
    __tablename__ = "city_images"

    id = Column(Integer, primary_key=True, index=True)
    city_id = Column(Integer, ForeignKey("cities.id"), nullable=False, index=True)
    image_url = Column(String, nullable=False)
    source = Column(String, default="wikimedia", nullable=False) # Track where it came from
    # Optional: Add fields like description, photographer, license_url if needed
    # Optional: A flag to mark a 'featured' or 'primary' image for the city
    is_featured = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationship back to City (Many Images belong to one City)
    city = relationship("City", back_populates="images")