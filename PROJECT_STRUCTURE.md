# Project Structure

This document outlines the complete structure of the Nonprofit Learning Platform.

## Root Directory

```
CodeGurus/
├── backend/              # FastAPI backend application
├── frontend/             # Next.js 14 frontend application
├── README.md            # Main project documentation
└── PROJECT_STRUCTURE.md # This file
```

## Backend Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI application entry point
│   │
│   ├── auth/                      # Authentication microservice (Clerk integration)
│   │   └── __init__.py
│   │
│   ├── users/                     # Users microservice
│   │   ├── __init__.py
│   │   ├── models.py             # User, Parent, Student, SessionEnrollment models
│   │   ├── schemas.py             # Pydantic schemas for users
│   │   ├── services.py            # Business logic for users
│   │   └── routers.py             # API endpoints for users
│   │
│   ├── skills/                    # Skills microservice
│   │   ├── __init__.py
│   │   ├── models.py             # Skill model
│   │   ├── schemas.py             # Pydantic schemas for skills
│   │   ├── services.py            # Business logic for skills
│   │   └── routers.py             # API endpoints for skills
│   │
│   ├── sessions/                  # Sessions microservice
│   │   ├── __init__.py
│   │   ├── models.py             # Session model
│   │   ├── schemas.py             # Pydantic schemas for sessions
│   │   ├── services.py            # Business logic for sessions
│   │   └── routers.py             # API endpoints for sessions
│   │
│   ├── videos/                    # Videos microservice
│   │   ├── __init__.py
│   │   ├── models.py             # Video model
│   │   ├── schemas.py             # Pydantic schemas for videos
│   │   ├── services.py            # Business logic for videos
│   │   └── routers.py             # API endpoints for videos
│   │
│   ├── core/                      # Core application configuration
│   │   ├── __init__.py
│   │   ├── config.py              # Application settings
│   │   ├── security.py            # Authentication & authorization utilities
│   │   └── dependencies.py        # FastAPI dependencies (RBAC)
│   │
│   └── db/                        # Database configuration
│       ├── __init__.py
│       └── database.py            # SQLAlchemy setup
│
├── alembic/                       # Database migrations
│   ├── versions/                  # Migration files
│   │   └── 001_initial_migration.py
│   ├── env.py                     # Alembic environment config
│   └── script.py.mako             # Migration template
│
├── alembic.ini                    # Alembic configuration
├── requirements.txt               # Python dependencies
├── env.example                    # Environment variables template
├── .gitignore                     # Git ignore rules
└── README.md                      # Backend documentation
```

## Frontend Structure

```
frontend/
├── app/                           # Next.js App Router
│   ├── layout.tsx                 # Root layout with ClerkProvider
│   ├── page.tsx                   # Landing page
│   ├── globals.css                # Global styles
│   ├── dashboard/                 # User dashboard
│   │   └── page.tsx
│   ├── admin/                     # Admin dashboard
│   │   └── page.tsx
│   ├── volunteer-signup/          # Volunteer registration
│   │   └── page.tsx
│   ├── parent-signup/             # Parent registration
│   │   └── page.tsx
│   ├── skills/                    # Skills pages
│   │   └── page.tsx
│   └── sessions/                  # Sessions pages
│       └── page.tsx
│
├── components/                    # React components (for future use)
│
├── lib/                           # Utilities and API client
│   └── api.ts                     # API service layer
│
├── types/                         # TypeScript type definitions
│   └── index.ts
│
├── public/                        # Static assets
│
├── middleware.ts                  # Clerk authentication middleware
├── next.config.js                 # Next.js configuration
├── package.json                   # Node.js dependencies
├── tsconfig.json                  # TypeScript configuration
├── .env.local.example             # Environment variables template
├── .gitignore                     # Git ignore rules
└── README.md                      # Frontend documentation
```

## Database Schema

### Tables

1. **users**
   - id (PK)
   - clerk_id (unique)
   - role (ADMIN, VOLUNTEER, PARENT)
   - approved (boolean)
   - created_at
   - updated_at

2. **parents**
   - id (PK)
   - user_id (FK → users.id, unique)
   - email
   - created_at

3. **students**
   - id (PK)
   - parent_id (FK → parents.id)
   - name
   - age
   - interests
   - created_at

4. **skills**
   - id (PK)
   - name
   - description
   - created_by (FK → users.id)
   - created_at
   - updated_at

5. **sessions**
   - id (PK)
   - skill_id (FK → skills.id)
   - volunteer_id (FK → users.id)
   - title
   - description
   - schedule
   - meeting_link
   - status
   - created_at
   - updated_at

6. **session_enrollments**
   - id (PK)
   - student_id (FK → students.id)
   - session_id (FK → sessions.id)
   - enrolled_at

7. **videos**
   - id (PK)
   - skill_id (FK → skills.id)
   - title
   - description
   - youtube_url
   - created_by (FK → users.id)
   - created_at
   - updated_at

## API Routes

All API routes are prefixed with `/api/v1`:

- `/api/v1/users/*` - User management
- `/api/v1/skills/*` - Skill management
- `/api/v1/sessions/*` - Session management
- `/api/v1/videos/*` - Video management
- `/api/v1/health` - Health check

## Frontend Routes

- `/` - Landing page
- `/dashboard` - User dashboard (role-based)
- `/admin` - Admin dashboard
- `/volunteer-signup` - Volunteer registration
- `/parent-signup` - Parent registration
- `/skills` - Browse skills
- `/sessions` - Browse sessions

## Security Architecture

1. **Authentication**: Clerk handles all authentication
2. **Authorization**: Role-based access control (RBAC) in both frontend and backend
3. **Token Verification**: JWT tokens verified on backend
4. **Input Validation**: Pydantic schemas validate all inputs
5. **Parent Email**: Required for all student accounts
6. **No Direct Messaging**: Students and volunteers cannot message directly
7. **Admin Approval**: Volunteers require admin approval
