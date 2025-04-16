# app/db/models/user_visit_history.py
from sqlalchemy import Column, Integer, DateTime, func, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class UserVisitHistory(Base):
    __tablename__ = "user_visit_history"

    id = Column(Integer, primary_key=True, index=True) # Added index=True for consistency
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    place_id = Column(Integer, ForeignKey("places.id", ondelete="CASCADE"), nullable=False, index=True)
    visited_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)

    # Optional: Relationships back to User and Place from the history entry itself
    user = relationship("User", back_populates="visit_history")
    place = relationship("Place") # No back_populates needed if Place doesn't need direct access history entries