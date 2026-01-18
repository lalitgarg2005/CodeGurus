"""
User routers - API endpoints for user operations.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.database import get_db
from app.core.dependencies import require_admin, require_parent, get_current_user
from app.users.models import User
from app.users.schemas import (
    UserCreate, UserResponse, UserUpdate,
    ParentCreate, ParentResponse,
    StudentCreate, StudentResponse, StudentUpdate
)
from app.users.services import UserService, ParentService, StudentService

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """
    Register a new user or update existing user's role.
    Auto-approves ADMIN and PARENT roles.
    VOLUNTEER requires admin approval.
    """
    user_service = UserService(db)
    
    # Check if user already exists
    existing_user = user_service.get_by_clerk_id(user_data.clerk_id)
    
    if existing_user:
        # User exists - update role if different
        if existing_user.role != user_data.role:
            # Update role and approval status
            existing_user.role = user_data.role
            if user_data.role in ["ADMIN", "PARENT"]:
                existing_user.approved = True
            elif user_data.role == "VOLUNTEER":
                # For VOLUNTEER, reset approval status (requires admin approval)
                existing_user.approved = False
            
            db.commit()
            db.refresh(existing_user)
            return existing_user
        else:
            # User already has this role - return existing user
            return existing_user
    else:
        # New user - create
        # Auto-approve ADMIN and PARENT, but not VOLUNTEER
        if user_data.role in ["ADMIN", "PARENT"]:
            user_data.approved = True
        
        user = user_service.create(user_data)
        return user


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """Get current authenticated user information."""
    return current_user


@router.get("/", response_model=List[UserResponse])
async def get_all_users(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Get all users (admin only)."""
    user_service = UserService(db)
    return user_service.get_all(skip=skip, limit=limit)


@router.get("/pending-volunteers", response_model=List[UserResponse])
async def get_pending_volunteers(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Get all pending volunteer approvals (admin only)."""
    user_service = UserService(db)
    return user_service.get_pending_volunteers()


@router.patch("/{user_id}/approve", response_model=UserResponse)
async def approve_user(
    user_id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """Approve a volunteer (admin only)."""
    user_service = UserService(db)
    update_data = UserUpdate(approved=True)
    return user_service.update(user_id, update_data)


# Parent endpoints
@router.post("/parents/register", response_model=ParentResponse, status_code=status.HTTP_201_CREATED)
async def register_parent(
    parent_data: ParentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Register as a parent.
    Requires parent email for student safety.
    """
    if current_user.role != "PARENT":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users with PARENT role can register as parents"
        )
    
    parent_service = ParentService(db)
    parent = parent_service.create(parent_data, current_user.id)
    return parent


@router.get("/parents/me", response_model=ParentResponse)
async def get_my_parent_info(
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """Get current parent's information."""
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found. Please complete registration."
        )
    return parent


# Student endpoints
@router.post("/students", response_model=StudentResponse, status_code=status.HTTP_201_CREATED)
async def create_student(
    student_data: StudentCreate,
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """
    Create a new student.
    Requires parent account with email.
    """
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found. Please complete parent registration first."
        )
    
    student_service = StudentService(db)
    student = student_service.create(student_data, parent.id)
    return student


@router.get("/students", response_model=List[StudentResponse])
async def get_my_students(
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """Get all students for current parent."""
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found"
        )
    
    return parent.students


@router.get("/students/{student_id}", response_model=StudentResponse)
async def get_student(
    student_id: int,
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """Get a specific student (must belong to current parent)."""
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
    
    return student


@router.patch("/students/{student_id}", response_model=StudentResponse)
async def update_student(
    student_id: int,
    student_data: StudentUpdate,
    current_user: User = Depends(require_parent),
    db: Session = Depends(get_db)
):
    """Update a student (must belong to current parent)."""
    parent_service = ParentService(db)
    parent = parent_service.get_by_user_id(current_user.id)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Parent account not found"
        )
    
    student_service = StudentService(db)
    return student_service.update(student_id, student_data, parent.id)
