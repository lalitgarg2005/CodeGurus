"""
Main FastAPI application.
"""
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.users.routers import router as users_router
from app.skills.routers import router as skills_router
from app.sessions.routers import router as sessions_router
from app.videos.routers import router as videos_router
from sqlalchemy import create_engine, text
from app.db.database import engine

# Create FastAPI app
app = FastAPI(
    title="Nonprofit Learning Platform API",
    description="Production-grade learning platform for students, volunteers, and parents",
    version="1.0.0",
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc"
)

logger = logging.getLogger("app")

# Log missing optional configuration on startup (don't block health checks)
@app.on_event("startup")
async def log_missing_config() -> None:
    missing = []
    if not settings.CLERK_SECRET_KEY:
        missing.append("CLERK_SECRET_KEY")
    if not settings.CLERK_PUBLISHABLE_KEY:
        missing.append("CLERK_PUBLISHABLE_KEY")
    if not settings.CLERK_FRONTEND_API:
        missing.append("CLERK_FRONTEND_API")
    if not settings.DATABASE_URL:
        missing.append("DATABASE_URL")

    if missing:
        logger.warning(
            "Missing environment variables: %s. App will start, but some features may fail.",
            ", ".join(missing),
        )

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users_router, prefix="/api/v1")
app.include_router(skills_router, prefix="/api/v1")
app.include_router(sessions_router, prefix="/api/v1")
app.include_router(videos_router, prefix="/api/v1")


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Nonprofit Learning Platform API",
        "version": "1.0.0",
        "docs": "/api/v1/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint for deployment monitoring."""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT
    }


@app.get("/api/v1/health")
async def api_health_check():
    """API health check endpoint."""
    return {
        "status": "healthy",
        "api_version": "v1",
        "environment": settings.ENVIRONMENT
    }


@app.get("/api/v1/health/db")
async def database_health_check():
    """Database health check endpoint."""
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            result.fetchone()
        return {
            "status": "healthy",
            "database": "connected",
            "database_url": settings.DATABASE_URL.split("@")[-1] if "@" in settings.DATABASE_URL else "sqlite"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }
