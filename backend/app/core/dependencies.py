"""
Dependency injection for FastAPI routes.
Handles role-based access control and user authentication.
"""
from typing import Optional
from fastapi import Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.core.security import verify_clerk_token
from app.users.models import User
from app.users.services import UserService


class RoleChecker:
    """Dependency to check if user has required role."""
    
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles
    
    def __call__(
        self,
        clerk_user: dict = Depends(verify_clerk_token),
        db: Session = Depends(get_db)
    ) -> User:
        """
        Verify user has required role.
        
        Args:
            clerk_user: User info from Clerk token
            db: Database session
            
        Returns:
            User: Database user object
            
        Raises:
            HTTPException: If user doesn't have required role
        """
        clerk_id = clerk_user.get("sub") or clerk_user.get("id")
        if not clerk_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token format"
            )
        
        # Get or create user in database
        user_service = UserService(db)
        user = user_service.get_by_clerk_id(clerk_id)
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found. Please complete registration."
            )
        
        # Check if user is approved (for volunteers)
        if user.role == "VOLUNTEER" and not user.approved:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your volunteer account is pending admin approval."
            )
        
        # Check role
        if user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required roles: {', '.join(self.allowed_roles)}"
            )
        
        return user


# Role-based dependencies
require_admin = RoleChecker(["ADMIN"])
require_volunteer = RoleChecker(["VOLUNTEER", "ADMIN"])
require_parent = RoleChecker(["PARENT", "ADMIN"])
require_any_auth = RoleChecker(["ADMIN", "VOLUNTEER", "PARENT"])


async def get_current_user(
    clerk_user: dict = Depends(verify_clerk_token),
    db: Session = Depends(get_db)
) -> User:
    """
    Get current authenticated user from database.
    
    Args:
        clerk_user: User info from Clerk token
        db: Database session
        
    Returns:
        User: Database user object
    """
    clerk_id = clerk_user.get("sub") or clerk_user.get("id")
    if not clerk_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token format"
        )
    
    user_service = UserService(db)
    user = user_service.get_by_clerk_id(clerk_id)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found. Please complete registration."
        )
    
    return user
