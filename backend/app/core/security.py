"""
Security utilities for authentication and authorization.
Integrates with Clerk for user authentication.
"""
from typing import Optional
from fastapi import HTTPException, Header, status
import httpx
from app.core.config import settings


async def verify_clerk_token(authorization: Optional[str] = Header(None)) -> dict:
    """
    Verify Clerk JWT token and return user information.
    
    Note: In production, you should use Clerk's backend SDK to verify tokens.
    This is a simplified version for demonstration.
    
    Args:
        authorization: Bearer token from Authorization header
        
    Returns:
        dict: User information from Clerk token
        
    Raises:
        HTTPException: If token is invalid or missing
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )
    
    try:
        token = authorization.replace("Bearer ", "")
        
        # IMPORTANT: In production, use Clerk's backend SDK for proper token verification:
        # Install: pip install clerk-backend-api
        # from clerk_backend_api import Clerk
        # clerk = Clerk(api_key=settings.CLERK_SECRET_KEY)
        # user = clerk.verify_token(token)
        
        # For development, we decode the JWT to get user info
        # In production, you MUST verify the token signature with Clerk's public keys
        from jose import jwt
        
        # Decode without verification for development (NOT for production!)
        # In production, fetch Clerk's public keys and verify the signature
        try:
            # jwt.decode requires a key parameter even with verify_signature=False
            # Use an empty string or any dummy key when not verifying
            decoded = jwt.decode(token, key="", options={"verify_signature": False})
            return {
                "sub": decoded.get("sub"),
                "id": decoded.get("sub"),
                "email": decoded.get("email"),
            }
        except Exception as decode_error:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid token format: {str(decode_error)}"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}"
        )


async def get_clerk_user_info(clerk_id: str) -> dict:
    """
    Get user information from Clerk API.
    
    Args:
        clerk_id: Clerk user ID
        
    Returns:
        dict: User information from Clerk
    """
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.CLERK_FRONTEND_API}/v1/users/{clerk_id}",
            headers={"Authorization": f"Bearer {settings.CLERK_SECRET_KEY}"}
        )
        
        if response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found in Clerk"
            )
        
        return response.json()
