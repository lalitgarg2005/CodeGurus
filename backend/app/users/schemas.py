"""
Pydantic schemas for user-related operations.
"""
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema."""
    role: str = Field(..., description="User role: ADMIN, VOLUNTEER, or PARENT")
    approved: bool = Field(default=False, description="Whether user is approved (for volunteers)")


class UserCreate(UserBase):
    """Schema for creating a new user."""
    clerk_id: str = Field(..., description="Clerk user ID")
    
    @validator('role')
    def validate_role(cls, v):
        allowed_roles = ['ADMIN', 'VOLUNTEER', 'PARENT']
        if v not in allowed_roles:
            raise ValueError(f'Role must be one of: {", ".join(allowed_roles)}')
        return v.upper()


class UserUpdate(BaseModel):
    """Schema for updating user information."""
    approved: Optional[bool] = None


class UserResponse(UserBase):
    """Schema for user response."""
    id: int
    clerk_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class ParentCreate(BaseModel):
    """Schema for creating a parent account."""
    email: EmailStr = Field(..., description="Parent email address (required for student safety)")
    clerk_id: str = Field(..., description="Clerk user ID")


class ParentResponse(BaseModel):
    """Schema for parent response."""
    id: int
    user_id: int
    email: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class StudentCreate(BaseModel):
    """Schema for creating a student."""
    name: str = Field(..., min_length=1, max_length=100, description="Student name")
    age: int = Field(..., ge=5, le=18, description="Student age (5-18)")
    interests: Optional[str] = Field(None, max_length=500, description="Student interests")


class StudentUpdate(BaseModel):
    """Schema for updating student information."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=5, le=18)
    interests: Optional[str] = Field(None, max_length=500)


class StudentResponse(BaseModel):
    """Schema for student response."""
    id: int
    parent_id: int
    name: str
    age: int
    interests: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


class StudentWithParent(StudentResponse):
    """Student response with parent information."""
    parent: ParentResponse
    
    class Config:
        from_attributes = True
