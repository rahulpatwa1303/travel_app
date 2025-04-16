from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class Country(Base):
    __tablename__ = "countries" # Explicit table name

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False, unique=True) # Assume name is unique
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationship to City: One Country has many Cities
    # 'back_populates' links this relationship to the 'country' attribute in the City model
    cities = relationship("City", back_populates="country")