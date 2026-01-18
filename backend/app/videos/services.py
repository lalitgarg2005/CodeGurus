"""
Video service layer - business logic for video operations.
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException, status
from app.videos.models import Video
from app.videos.schemas import VideoCreate, VideoUpdate
from app.skills.models import Skill


class VideoService:
    """Service for video-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, video_id: int) -> Optional[Video]:
        """Get video by ID."""
        return self.db.query(Video).filter(Video.id == video_id).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Video]:
        """Get all videos with pagination."""
        return self.db.query(Video).offset(skip).limit(limit).all()
    
    def get_by_skill(self, skill_id: int) -> List[Video]:
        """Get all videos for a skill."""
        return self.db.query(Video).filter(Video.skill_id == skill_id).all()
    
    def create(self, video_data: VideoCreate, created_by: int) -> Video:
        """Create a new video entry (stores YouTube URL only)."""
        # Verify skill exists
        skill = self.db.query(Skill).filter(Skill.id == video_data.skill_id).first()
        if not skill:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Skill not found"
            )
        
        video = Video(
            **video_data.dict(),
            created_by=created_by
        )
        self.db.add(video)
        self.db.commit()
        self.db.refresh(video)
        return video
    
    def update(self, video_id: int, video_data: VideoUpdate, created_by: int) -> Video:
        """Update a video."""
        video = self.get_by_id(video_id)
        if not video:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Video not found"
            )
        
        # Verify user owns this video (or is admin)
        if video.created_by != created_by:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only update your own videos"
            )
        
        update_data = video_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(video, field, value)
        
        self.db.commit()
        self.db.refresh(video)
        return video
    
    def delete(self, video_id: int, created_by: int) -> None:
        """Delete a video."""
        video = self.get_by_id(video_id)
        if not video:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Video not found"
            )
        
        # Verify user owns this video
        if video.created_by != created_by:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own videos"
            )
        
        self.db.delete(video)
        self.db.commit()
