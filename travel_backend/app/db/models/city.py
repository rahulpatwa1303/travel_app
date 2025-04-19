# app/db/models/city.py
from sqlalchemy import Column, Float, Integer, SmallInteger, String, DateTime, func, ForeignKey # Ensure ForeignKey is imported
from sqlalchemy.orm import relationship  # Ensure relationship is imported
from app.db.base_class import Base
# Import related models only for type hinting if needed, avoid circular imports at runtime

# class City(Base):
#     __tablename__ = "cities"

#     id = Column(Integer, primary_key=True, index=True)
#     name = Column(String, index=True, nullable=False)

#     # --- Foreign Key to Country ---
#     country_id = Column(Integer, ForeignKey("countries.id"), nullable=False) # Assuming city must have country

#     created_at = Column(DateTime(timezone=True), server_default=func.now())

#     # --- Relationships ---

#     # Relationship to Country model (Many Cities to One Country)
#     # 'back_populates' links this to the 'cities' attribute in the Country model
#     country = relationship("Country", back_populates="cities")

#     # Relationship to Place model (One City to Many Places)
#     # 'back_populates' links this to the 'city' attribute in the Place model
#     # cascade="all, delete-orphan" could be added if deleting a city should delete its places
#     places = relationship("Place", back_populates="city") # No cascade by default here

#     # Relationship to CityImage model (One City to Many Images)
#     # 'back_populates' links to the 'city' attribute in CityImage
#     images = relationship("CityImage", back_populates="city", cascade="all, delete-orphan")
# app/db/models/city.py
from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey, Text, BigInteger # Import Text, BigInteger if needed
from sqlalchemy.dialects.postgresql import JSONB # Import JSONB
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class City(Base):
    __tablename__ = "cities"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    country_id = Column(Integer, ForeignKey("countries.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # --- ADD THE NEW CACHED COLUMNS HERE ---
    description = Column(Text, nullable=True)
    best_time_to_travel = Column(Text, nullable=True)
    famous_for = Column(Text, nullable=True)
    timezone = Column(String(100), nullable=True)
    population = Column(BigInteger, nullable=True) # Use BigInteger for potentially large numbers
    wikidata_id = Column(String(50), nullable=True, index=True)
    details_last_updated = Column(DateTime(timezone=True), nullable=True)
    cached_weather = Column(JSONB, nullable=True)
    weather_last_updated = Column(DateTime(timezone=True), nullable=True)
    budget_scale = Column(SmallInteger, nullable=True) # Added
    budget_summary = Column(Text, nullable=True) # Added
    # latitude = Column(Float, nullable=True)
    # longitude = Column(Float, nullable=True)

    # --- END OF NEW COLUMNS ---

    # --- Relationships ---
    country = relationship("Country", back_populates="cities")
    places = relationship("Place", back_populates="city")
    images = relationship("CityImage", back_populates="city", cascade="all, delete-orphan")