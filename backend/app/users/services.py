"""
User service layer - business logic for user operations.
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException, status
from app.users.models import User, Parent, Student
from app.users.schemas import UserCreate, UserUpdate, ParentCreate, StudentCreate, StudentUpdate


class UserService:
    """Service for user-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        return self.db.query(User).filter(User.id == user_id).first()
    
    def get_by_clerk_id(self, clerk_id: str) -> Optional[User]:
        """Get user by Clerk ID."""
        return self.db.query(User).filter(User.clerk_id == clerk_id).first()
    
    def create(self, user_data: UserCreate) -> User:
        """Create a new user."""
        # Check if user already exists
        existing = self.get_by_clerk_id(user_data.clerk_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this Clerk ID already exists"
            )
        
        user = User(**user_data.dict())
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def update(self, user_id: int, user_data: UserUpdate) -> User:
        """Update user information."""
        user = self.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        update_data = user_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)
        
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Get all users with pagination."""
        return self.db.query(User).offset(skip).limit(limit).all()
    
    def get_pending_volunteers(self) -> List[User]:
        """Get all pending volunteer approvals."""
        return self.db.query(User).filter(
            User.role == "VOLUNTEER",
            User.approved == False
        ).all()


class ParentService:
    """Service for parent-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_user_id(self, user_id: int) -> Optional[Parent]:
        """Get parent by user ID."""
        return self.db.query(Parent).filter(Parent.user_id == user_id).first()
    
    def get_by_email(self, email: str) -> Optional[Parent]:
        """Get parent by email."""
        return self.db.query(Parent).filter(Parent.email == email).first()
    
    def create(self, parent_data: ParentCreate, user_id: int) -> Parent:
        """Create a new parent account."""
        # Check if parent already exists
        existing = self.get_by_user_id(user_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Parent account already exists for this user"
            )
        
        # Check if email is already in use
        email_exists = self.get_by_email(parent_data.email)
        if email_exists:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        parent = Parent(
            user_id=user_id,
            email=parent_data.email
        )
        self.db.add(parent)
        self.db.commit()
        self.db.refresh(parent)
        return parent
    
    def get_students(self, parent_id: int) -> List[Student]:
        """Get all students for a parent."""
        parent = self.db.query(Parent).filter(Parent.id == parent_id).first()
        if not parent:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Parent not found"
            )
        return parent.students


class StudentService:
    """Service for student-related operations."""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, student_id: int) -> Optional[Student]:
        """Get student by ID."""
        return self.db.query(Student).filter(Student.id == student_id).first()
    
    def create(self, student_data: StudentCreate, parent_id: int) -> Student:
        """Create a new student."""
        # Verify parent exists
        parent = self.db.query(Parent).filter(Parent.id == parent_id).first()
        if not parent:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Parent not found"
            )
        
        student = Student(
            parent_id=parent_id,
            **student_data.dict()
        )
        self.db.add(student)
        self.db.commit()
        self.db.refresh(student)
        return student
    
    def update(self, student_id: int, student_data: StudentUpdate, parent_id: int) -> Student:
        """Update student information."""
        student = self.get_by_id(student_id)
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found"
            )
        
        # Verify parent owns this student
        if student.parent_id != parent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only update your own students"
            )
        
        update_data = student_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(student, field, value)
        
        self.db.commit()
        self.db.refresh(student)
        return student
    
    def get_by_parent(self, parent_id: int) -> List[Student]:
        """Get all students for a parent."""
        return self.db.query(Student).filter(Student.parent_id == parent_id).all()
