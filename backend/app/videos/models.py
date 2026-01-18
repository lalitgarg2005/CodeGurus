"""
Video models for storing YouTube video links.
"""
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base


class Video(Base):
    """
    Video model - stores YouTube video URLs (unlisted videos only).
    No raw video uploads - only URLs are stored.
    """
    __tablename__ = "videos"
    
    id = Column(Integer, primary_key=True, index=True)
    skill_id = Column(Integer, ForeignKey("skills.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    youtube_url = Column(String, nullable=False)  # Full YouTube URL
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    skill = relationship("Skill", back_populates="videos")
