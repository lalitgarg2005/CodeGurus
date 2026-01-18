"""
User models for the application.
"""
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base


class User(Base):
    """
    Base user model with role-based access control.
    Links to Clerk for authentication.
    """
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    clerk_id = Column(String, unique=True, index=True, nullable=False)
    role = Column(String, nullable=False)  # ADMIN, VOLUNTEER, PARENT
    approved = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    parent = relationship("Parent", back_populates="user", uselist=False)
    volunteer_sessions = relationship("Session", back_populates="volunteer", foreign_keys="Session.volunteer_id")


class Parent(Base):
    """
    Parent model - stores parent-specific information.
    Required for student registration.
    """
    __tablename__ = "parents"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    email = Column(String, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="parent")
    students = relationship("Student", back_populates="parent")


class Student(Base):
    """
    Student model - represents children enrolled in the platform.
    Must be linked to a parent account.
    """
    __tablename__ = "students"
    
    id = Column(Integer, primary_key=True, index=True)
    parent_id = Column(Integer, ForeignKey("parents.id"), nullable=False)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    interests = Column(Text, nullable=True)  # JSON string or comma-separated
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    parent = relationship("Parent", back_populates="students")
    enrollments = relationship("SessionEnrollment", back_populates="student")


class SessionEnrollment(Base):
    """
    Many-to-many relationship between students and sessions.
    Tracks which students are enrolled in which sessions.
    """
    __tablename__ = "session_enrollments"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    session_id = Column(Integer, ForeignKey("sessions.id"), nullable=False)
    enrolled_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    student = relationship("Student", back_populates="enrollments")
    session = relationship("Session", back_populates="enrollments")
