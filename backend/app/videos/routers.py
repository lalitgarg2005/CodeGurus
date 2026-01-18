"""
Video routers - API endpoints for video operations.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.core.dependencies import require_volunteer, require_any_auth, get_current_user
from app.users.models import User
from app.videos.schemas import VideoCreate, VideoResponse, VideoUpdate
from app.videos.services import VideoService

router = APIRouter(prefix="/videos", tags=["videos"])


@router.post("/", response_model=VideoResponse, status_code=status.HTTP_201_CREATED)
async def create_video(
    video_data: VideoCreate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """
    Create a new video entry.
    Stores YouTube URL only (no raw video uploads).
    Volunteers can upload video links for skills.
    """
    video_service = VideoService(db)
    video = video_service.create(video_data, current_user.id)
    return video


@router.get("/", response_model=List[VideoResponse])
async def get_all_videos(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get all videos (authenticated users only)."""
    video_service = VideoService(db)
    return video_service.get_all(skip=skip, limit=limit)


@router.get("/skill/{skill_id}", response_model=List[VideoResponse])
async def get_videos_by_skill(
    skill_id: int,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get all videos for a specific skill."""
    video_service = VideoService(db)
    return video_service.get_by_skill(skill_id)


@router.get("/{video_id}", response_model=VideoResponse)
async def get_video(
    video_id: int,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get a specific video by ID."""
    video_service = VideoService(db)
    video = video_service.get_by_id(video_id)
    if not video:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Video not found"
        )
    return video


@router.patch("/{video_id}", response_model=VideoResponse)
async def update_video(
    video_id: int,
    video_data: VideoUpdate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Update a video (only by creator or admin)."""
    video_service = VideoService(db)
    video = video_service.update(video_id, video_data, current_user.id)
    return video


@router.delete("/{video_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_video(
    video_id: int,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Delete a video (only by creator)."""
    video_service = VideoService(db)
    video_service.delete(video_id, current_user.id)
