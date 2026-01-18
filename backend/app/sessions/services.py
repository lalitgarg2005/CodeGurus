"""
Session service layer - business logic for session operations.
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException, status
from app.sessions.models import Session
from app.users.models import SessionEnrollment
from app.sessions.schemas import SessionCreate, SessionUpdate, SessionEnrollmentCreate
from app.skills.models import Skill


class SessionService:
    """Service for session-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, session_id: int) -> Optional[Session]:
        """Get session by ID."""
        return self.db.query(Session).filter(Session.id == session_id).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Session]:
        """Get all sessions with pagination."""
        return self.db.query(Session).offset(skip).limit(limit).all()
    
    def get_by_volunteer(self, volunteer_id: int) -> List[Session]:
        """Get all sessions for a volunteer."""
        return self.db.query(Session).filter(Session.volunteer_id == volunteer_id).all()
    
    def get_by_skill(self, skill_id: int) -> List[Session]:
        """Get all sessions for a skill."""
        return self.db.query(Session).filter(Session.skill_id == skill_id).all()
    
    def create(self, session_data: SessionCreate, volunteer_id: int) -> Session:
        """Create a new session."""
        # Verify skill exists
        skill = self.db.query(Skill).filter(Skill.id == session_data.skill_id).first()
        if not skill:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Skill not found"
            )
        
        session = Session(
            **session_data.dict(),
            volunteer_id=volunteer_id
        )
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session
    
    def update(self, session_id: int, session_data: SessionUpdate, volunteer_id: int) -> Session:
        """Update a session."""
        session = self.get_by_id(session_id)
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found"
            )
        
        # Verify volunteer owns this session (or is admin)
        if session.volunteer_id != volunteer_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only update your own sessions"
            )
        
        update_data = session_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(session, field, value)
        
        self.db.commit()
        self.db.refresh(session)
        return session
    
    def delete(self, session_id: int, volunteer_id: int) -> None:
        """Delete a session."""
        session = self.get_by_id(session_id)
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found"
            )
        
        # Verify volunteer owns this session
        if session.volunteer_id != volunteer_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own sessions"
            )
        
        self.db.delete(session)
        self.db.commit()


class SessionEnrollmentService:
    """Service for session enrollment operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def enroll_student(self, enrollment_data: SessionEnrollmentCreate, parent_id: int) -> SessionEnrollment:
        """Enroll a student in a session."""
        # Verify session exists
        session = self.db.query(Session).filter(Session.id == enrollment_data.session_id).first()
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Session not found"
            )
        
        # Verify student belongs to parent
        from app.users.models import Student
        student = self.db.query(Student).filter(
            Student.id == enrollment_data.student_id,
            Student.parent_id == parent_id
        ).first()
        
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found or does not belong to you"
            )
        
        # Check if already enrolled
        existing = self.db.query(SessionEnrollment).filter(
            SessionEnrollment.student_id == enrollment_data.student_id,
            SessionEnrollment.session_id == enrollment_data.session_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student is already enrolled in this session"
            )
        
        enrollment = SessionEnrollment(**enrollment_data.dict())
        self.db.add(enrollment)
        self.db.commit()
        self.db.refresh(enrollment)
        return enrollment
    
    def get_student_enrollments(self, student_id: int) -> List[SessionEnrollment]:
        """Get all enrollments for a student."""
        return self.db.query(SessionEnrollment).filter(
            SessionEnrollment.student_id == student_id
        ).all()
    
    def get_session_enrollments(self, session_id: int) -> List[SessionEnrollment]:
        """Get all enrollments for a session."""
        return self.db.query(SessionEnrollment).filter(
            SessionEnrollment.session_id == session_id
        ).all()
