"""
Pydantic schemas for skill-related operations.
"""
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime


class SkillBase(BaseModel):
    """Base skill schema."""
    name: str = Field(..., min_length=1, max_length=100, description="Skill name")
    description: Optional[str] = Field(None, max_length=1000, description="Skill description")


class SkillCreate(SkillBase):
    """Schema for creating a new skill."""
    pass


class SkillUpdate(BaseModel):
    """Schema for updating a skill."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=1000)


class SkillResponse(SkillBase):
    """Schema for skill response."""
    id: int
    created_by: Optional[int]
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True
