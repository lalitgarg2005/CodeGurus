"""
Application configuration using Pydantic settings.
"""
from pydantic_settings import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Database - defaults to SQLite for easy development setup
    DATABASE_URL: str = "sqlite:///./nonprofit_learning.db"
    
    # Clerk (optional at startup; warn if missing)
    CLERK_SECRET_KEY: str = ""
    CLERK_PUBLISHABLE_KEY: str = ""
    CLERK_FRONTEND_API: str = ""
    
    # Application
    ENVIRONMENT: str = "development"
    CORS_ORIGINS: str = "http://localhost:3000"
    
    # AWS
    AWS_REGION: str = "us-east-1"
    RDS_ENDPOINT: str = ""
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Parse CORS origins from comma-separated string."""
        origins = [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]
        return origins or ["*"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"  # Ignore extra fields in .env file


settings = Settings()
