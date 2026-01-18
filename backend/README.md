# Backend - Nonprofit Learning Platform

FastAPI backend with microservices architecture for the nonprofit learning platform.

## Structure

```
backend/
├── app/
│   ├── auth/              # Clerk authentication integration
│   ├── users/             # User, Parent, Student management
│   │   ├── models.py    # SQLAlchemy models
│   │   ├── schemas.py    # Pydantic schemas
│   │   ├── services.py   # Business logic
│   │   └── routers.py    # API endpoints
│   ├── skills/           # Skill management microservice
│   ├── sessions/         # Session management microservice
│   ├── videos/           # Video management microservice
│   ├── core/             # Configuration, security, dependencies
│   ├── db/               # Database configuration
│   └── main.py           # FastAPI application
├── alembic/              # Database migrations
└── requirements.txt      # Python dependencies
```

## Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run migrations:**
   ```bash
   alembic upgrade head
   ```

4. **Start server:**
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

## API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/api/v1/docs`
- ReDoc: `http://localhost:8000/api/v1/redoc`

## Environment Variables

See `.env.example` for required environment variables.

## Database Migrations

```bash
# Create new migration
alembic revision --autogenerate -m "Description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```
