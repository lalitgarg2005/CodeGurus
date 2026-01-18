"""
Session models for scheduled learning sessions.
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base


class Session(Base):
    """
    Session model - represents a scheduled learning session.
    Created by volunteers, linked to a skill.
    """
    __tablename__ = "sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    skill_id = Column(Integer, ForeignKey("skills.id"), nullable=False)
    volunteer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    schedule = Column(DateTime(timezone=True), nullable=False)
    meeting_link = Column(String, nullable=True)  # Zoom, Google Meet, etc.
    status = Column(String, default="scheduled")  # scheduled, completed, cancelled
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    skill = relationship("Skill", back_populates="sessions")
    volunteer = relationship("User", back_populates="volunteer_sessions", foreign_keys=[volunteer_id])
    enrollments = relationship("SessionEnrollment", back_populates="session")
