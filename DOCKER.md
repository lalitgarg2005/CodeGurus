# Docker Setup Guide

This guide explains how to run the Nonprofit Learning Platform using Docker.

## Prerequisites

- Docker Desktop installed (or Docker Engine + Docker Compose)
- Docker version 20.10+
- Docker Compose version 2.0+

## Quick Start

### Option 1: Using Makefile (Easiest)

```bash
# Development mode (recommended for local development)
make dev

# Or manually:
make build
make up
```

### Option 2: Using Docker Compose Directly

**1. Set up environment variables**

Create a `.env` file in the project root:

```bash
cp .env.docker .env
```

Edit `.env` with your Clerk credentials:
```env
CLERK_SECRET_KEY=sk_test_your_key
CLERK_PUBLISHABLE_KEY=pk_test_your_key
CLERK_FRONTEND_API=https://your-app.clerk.accounts.dev
```

**2. Run with Docker Compose**

**Development mode (with hot reload):**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

**Production mode:**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Access the application

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/api/v1/docs
- PostgreSQL: localhost:5432

## Services

### PostgreSQL
- Port: 5432
- Database: `nonprofit_learning` (or from DB_NAME env var)
- User: `postgres` (or from DB_USER env var)
- Password: `postgres` (or from DB_PASSWORD env var)

### Backend
- Port: 8000
- Auto-runs migrations on startup
- Hot reload in development mode

### Frontend
- Port: 3000
- Hot reload in development mode

## Common Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### Rebuild containers
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Run database migrations manually
```bash
docker-compose exec backend alembic upgrade head
```

### Access database
```bash
docker-compose exec postgres psql -U postgres -d nonprofit_learning
```

### Access backend shell
```bash
docker-compose exec backend bash
```

### Access frontend shell
```bash
docker-compose exec frontend sh
```

### Remove everything (including volumes)
```bash
docker-compose down -v
```

## Development vs Production

### Development Mode (`docker-compose.dev.yml`)
- Hot reload enabled
- Source code mounted as volumes
- Development dependencies included
- More verbose logging

### Production Mode (`docker-compose.yml`)
- Optimized builds
- Standalone Next.js output
- Production dependencies only
- Health checks enabled

## Troubleshooting

### Port already in use
If ports 3000, 8000, or 5432 are in use:
```bash
# Stop local services using these ports
# Or change ports in docker-compose.yml
```

### Database connection errors
```bash
# Check if postgres is healthy
docker-compose ps

# Check postgres logs
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres
```

### Backend not starting
```bash
# Check backend logs
docker-compose logs backend

# Rebuild backend
docker-compose build backend
docker-compose up -d backend
```

### Frontend build errors
```bash
# Clear Next.js cache
docker-compose exec frontend rm -rf .next

# Rebuild frontend
docker-compose build frontend --no-cache
docker-compose up -d frontend
```

### Permission errors
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

## Environment Variables

Key environment variables needed in `.env`:

```env
# Database
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=nonprofit_learning

# Clerk (Required)
CLERK_SECRET_KEY=sk_test_...
CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_FRONTEND_API=https://your-app.clerk.accounts.dev

# Application
ENVIRONMENT=production
```

## Data Persistence

Database data is persisted in Docker volumes:
- `postgres_data` (production)
- `postgres_data_dev` (development)

To backup:
```bash
docker-compose exec postgres pg_dump -U postgres nonprofit_learning > backup.sql
```

To restore:
```bash
docker-compose exec -T postgres psql -U postgres nonprofit_learning < backup.sql
```

## Building Individual Services

### Backend only
```bash
cd backend
docker build -t nonprofit-backend .
docker run -p 8000:8000 --env-file ../.env nonprofit-backend
```

### Frontend only
```bash
cd frontend
docker build -t nonprofit-frontend .
docker run -p 3000:3000 --env-file ../.env nonprofit-frontend
```

## Production Deployment

For production deployment:

1. **Update environment variables** in `.env`
2. **Use production docker-compose:**
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
3. **Set up reverse proxy** (nginx/traefik) for SSL
4. **Configure backups** for PostgreSQL
5. **Set up monitoring** and logging

## AWS Deployment

For AWS deployment:

1. **Backend**: Use AWS App Runner or ECS
2. **Frontend**: Use AWS Amplify or S3 + CloudFront
3. **Database**: Use AWS RDS PostgreSQL
4. **Update DATABASE_URL** to point to RDS endpoint

## Health Checks

All services include health checks:
- Backend: `GET /health`
- Database: `pg_isready`
- Frontend: Built-in Next.js health

Check health:
```bash
docker-compose ps
```

## Cleanup

Remove all containers, networks, and volumes:
```bash
docker-compose down -v --remove-orphans
```

Remove images:
```bash
docker rmi nonprofit_learning_backend nonprofit_learning_frontend
```
