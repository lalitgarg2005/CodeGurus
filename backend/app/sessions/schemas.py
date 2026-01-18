"""
Pydantic schemas for session-related operations.
"""
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime


class SessionBase(BaseModel):
    """Base session schema."""
    skill_id: int = Field(..., description="ID of the skill this session teaches")
    title: str = Field(..., min_length=1, max_length=200, description="Session title")
    description: Optional[str] = Field(None, max_length=2000, description="Session description")
    schedule: datetime = Field(..., description="Scheduled date and time for the session")
    meeting_link: Optional[str] = Field(None, max_length=500, description="Meeting link (Zoom, Google Meet, etc.)")
    
    @validator('meeting_link')
    def validate_meeting_link(cls, v):
        if v and not (v.startswith('http://') or v.startswith('https://')):
            raise ValueError('Meeting link must be a valid URL')
        return v


class SessionCreate(SessionBase):
    """Schema for creating a new session."""
    pass


class SessionUpdate(BaseModel):
    """Schema for updating a session."""
    skill_id: Optional[int] = None
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    schedule: Optional[datetime] = None
    meeting_link: Optional[str] = Field(None, max_length=500)
    status: Optional[str] = Field(None, description="Session status: scheduled, completed, cancelled")
    
    @validator('status')
    def validate_status(cls, v):
        if v and v not in ['scheduled', 'completed', 'cancelled']:
            raise ValueError('Status must be one of: scheduled, completed, cancelled')
        return v


class SessionResponse(SessionBase):
    """Schema for session response."""
    id: int
    volunteer_id: int
    status: str
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class SessionEnrollmentCreate(BaseModel):
    """Schema for enrolling a student in a session."""
    student_id: int = Field(..., description="ID of the student to enroll")
    session_id: int = Field(..., description="ID of the session")


class SessionEnrollmentResponse(BaseModel):
    """Schema for enrollment response."""
    id: int
    student_id: int
    session_id: int
    enrolled_at: datetime
    
    class Config:
        from_attributes = True
