# app/schemas/user_activity.py
from pydantic import BaseModel
import datetime
from .place import Place # Import the basic Place schema for list view

# Schema for representing a single entry in the visit history list
class VisitHistoryEntry(BaseModel):
    place: Place # Embed the basic place details
    visited_at: datetime.datetime

    class Config:
        orm_mode = True # Pydantic V1. Use from_attributes = True for V2