"""
Skill routers - API endpoints for skill operations.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.core.dependencies import require_volunteer, require_any_auth, get_current_user
from app.users.models import User
from app.skills.schemas import SkillCreate, SkillResponse, SkillUpdate
from app.skills.services import SkillService

router = APIRouter(prefix="/skills", tags=["skills"])


@router.post("/", response_model=SkillResponse, status_code=status.HTTP_201_CREATED)
async def create_skill(
    skill_data: SkillCreate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """
    Create a new skill.
    Volunteers and admins can create skills.
    """
    skill_service = SkillService(db)
    skill = skill_service.create(skill_data, current_user.id)
    return skill


@router.get("/", response_model=List[SkillResponse])
async def get_all_skills(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get all skills (authenticated users only)."""
    skill_service = SkillService(db)
    return skill_service.get_all(skip=skip, limit=limit)


@router.get("/{skill_id}", response_model=SkillResponse)
async def get_skill(
    skill_id: int,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get a specific skill by ID."""
    skill_service = SkillService(db)
    skill = skill_service.get_by_id(skill_id)
    if not skill:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Skill not found"
        )
    return skill


@router.patch("/{skill_id}", response_model=SkillResponse)
async def update_skill(
    skill_id: int,
    skill_data: SkillUpdate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Update a skill."""
    skill_service = SkillService(db)
    skill = skill_service.update(skill_id, skill_data)
    return skill


@router.delete("/{skill_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_skill(
    skill_id: int,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Delete a skill."""
    skill_service = SkillService(db)
    skill_service.delete(skill_id)
