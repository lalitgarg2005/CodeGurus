"""
Skill service layer - business logic for skill operations.
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException, status
from app.skills.models import Skill
from app.skills.schemas import SkillCreate, SkillUpdate


class SkillService:
    """Service for skill-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, skill_id: int) -> Optional[Skill]:
        """Get skill by ID."""
        return self.db.query(Skill).filter(Skill.id == skill_id).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Skill]:
        """Get all skills with pagination."""
        return self.db.query(Skill).offset(skip).limit(limit).all()
    
    def create(self, skill_data: SkillCreate, created_by: int) -> Skill:
        """Create a new skill."""
        skill = Skill(
            **skill_data.dict(),
            created_by=created_by
        )
        self.db.add(skill)
        self.db.commit()
        self.db.refresh(skill)
        return skill
    
    def update(self, skill_id: int, skill_data: SkillUpdate) -> Skill:
        """Update a skill."""
        skill = self.get_by_id(skill_id)
        if not skill:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Skill not found"
            )
        
        update_data = skill_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(skill, field, value)
        
        self.db.commit()
        self.db.refresh(skill)
        return skill
    
    def delete(self, skill_id: int) -> None:
        """Delete a skill."""
        skill = self.get_by_id(skill_id)
        if not skill:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Skill not found"
            )
        
        self.db.delete(skill)
        self.db.commit()
