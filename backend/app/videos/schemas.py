"""
Pydantic schemas for video-related operations.
"""
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
import re


class VideoBase(BaseModel):
    """Base video schema."""
    skill_id: int = Field(..., description="ID of the skill this video teaches")
    title: str = Field(..., min_length=1, max_length=200, description="Video title")
    description: Optional[str] = Field(None, max_length=2000, description="Video description")
    youtube_url: str = Field(..., description="YouTube video URL (unlisted videos only)")
    
    @validator('youtube_url')
    def validate_youtube_url(cls, v):
        """Validate that the URL is a YouTube URL."""
        youtube_pattern = r'(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})'
        if not re.match(youtube_pattern, v) and not v.startswith('https://www.youtube.com/') and not v.startswith('https://youtu.be/'):
            raise ValueError('Must be a valid YouTube URL')
        return v


class VideoCreate(VideoBase):
    """Schema for creating a new video."""
    pass


class VideoUpdate(BaseModel):
    """Schema for updating a video."""
    skill_id: Optional[int] = None
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    youtube_url: Optional[str] = None
    
    @validator('youtube_url')
    def validate_youtube_url(cls, v):
        if v:
            youtube_pattern = r'(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})'
            if not re.match(youtube_pattern, v) and not v.startswith('https://www.youtube.com/') and not v.startswith('https://youtu.be/'):
                raise ValueError('Must be a valid YouTube URL')
        return v


class VideoResponse(VideoBase):
    """Schema for video response."""
    id: int
    created_by: Optional[int]
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True
