"""
Session routers - API endpoints for session operations.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.core.dependencies import require_volunteer, require_parent, require_any_auth, get_current_user
from app.users.models import User
from app.sessions.schemas import (
    SessionCreate, SessionResponse, SessionUpdate,
    SessionEnrollmentCreate, SessionEnrollmentResponse
)
from app.sessions.services import SessionService, SessionEnrollmentService

router = APIRouter(prefix="/sessions", tags=["sessions"])


@router.post("/", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    session_data: SessionCreate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """
    Create a new session.
    Volunteers can create sessions for skills they've created.
    """
    session_service = SessionService(db)
    session = session_service.create(session_data, current_user.id)
    return session


@router.get("/", response_model=List[SessionResponse])
async def get_all_sessions(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get all sessions (authenticated users only)."""
    session_service = SessionService(db)
    return session_service.get_all(skip=skip, limit=limit)


@router.get("/my-sessions", response_model=List[SessionResponse])
async def get_my_sessions(
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Get all sessions created by current volunteer."""
    session_service = SessionService(db)
    return session_service.get_by_volunteer(current_user.id)


@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: int,
    current_user: User = Depends(require_any_auth),
    db: Session = Depends(get_db)
):
    """Get a specific session by ID."""
    session_service = SessionService(db)
    session = session_service.get_by_id(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )
    return session


@router.patch("/{session_id}", response_model=SessionResponse)
async def update_session(
    session_id: int,
    session_data: SessionUpdate,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Update a session (only by creator or admin)."""
    session_service = SessionService(db)
    session = session_service.update(session_id, session_data, current_user.id)
    return session


@router.delete("/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: int,
    current_user: User = Depends(require_volunteer),
    db: Session = Depends(get_db)
):
    """Delete a session (only by creator)."""
    session_service = SessionService(db)
    session_service.delete(session_id, current_user.id)


# Enrollment endpoints
@router.post("/enroll", response_model=SessionEnrollmentResponse, status_code=status.HTTP_201_CREATED)
async def enroll_student(
    enrollment_data: SessionEnrollmentCreate,
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """
    Enroll a student in a session.
    Parents can enroll their children in sessions.
    """
    # Get parent ID
    from app.users.services import ParentService
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found"
        )
    
    enrollment_service = SessionEnrollmentService(db)
    enrollment = enrollment_service.enroll_student(enrollment_data, parent.id)
    return enrollment


@router.get("/students/{student_id}/enrollments", response_model=List[SessionEnrollmentResponse])
async def get_student_enrollments(
    student_id: int,
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """Get all enrollments for a student (parent only)."""
    # Verify student belongs to parent
    from app.users.services import ParentService, StudentService
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found"
        )
    
    student_service = StudentService(db)
    student = student_service.get_by_id(student_id)
    if not student or student.parent_id != parent.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found"
        )
    
    enrollment_service = SessionEnrollmentService(db)
    return enrollment_service.get_student_enrollments(student_id)
