from pydantic import BaseModel, EmailStr
from typing import Optional
import datetime

# Shared properties
class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = True
    is_superuser: bool = False
    full_name: Optional[str] = None

# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str

# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str] = None

# Properties stored in DB (used by UserInDB)
class UserInDBBase(UserBase):
    id: Optional[int] = None
    created_at: Optional[datetime.datetime] = None
    updated_at: Optional[datetime.datetime] = None

    class Config:
        orm_mode = True # Pydantic V1. For V2: from_attributes = True

# Additional properties stored in DB
class UserInDB(UserInDBBase):
    hashed_password: str
    refresh_token: Optional[str] = None # Include refresh token if needed internally

# Additional properties to return to client (never include password hash)
class User(UserInDBBase):
    pass # Inherits fields from UserInDBBase suitable for response