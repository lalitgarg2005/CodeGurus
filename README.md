# Nonprofit Learning Platform

A production-grade, student-safe nonprofit learning platform built with Next.js 14 and FastAPI. This platform connects students with volunteer teachers in a secure, supervised environment.

## 🏗️ Architecture

The project is organized into two main directories:

- **`/backend`**: FastAPI microservices application
- **`/frontend`**: Next.js 14 application with App Router

### Backend Structure

```
backend/
├── app/
│   ├── auth/          # Clerk integration (authentication)
│   ├── users/          # User, Parent, Student management
│   ├── skills/         # Skill management
│   ├── sessions/       # Session scheduling and enrollment
│   ├── videos/         # Video URL management (YouTube only
│   ├── core/           # Configuration and security
│   └── db/             # Database configuration
├── alembic/            # Database migrations
└── requirements.txt    # Python dependencies
```

### Frontend Structure

```
frontend/
├── app/                # Next.js App Router pages
├── components/         # React components
├── lib/                # API client and utilities
├── types/              # TypeScript type definitions
└── public/             # Static assets
```

## 🔐 Security Features

- **Parent Email Required**: All student accounts must be linked to a parent email
- **No Direct Messaging**: Students and volunteers cannot message each other directly
- **Admin Approval**: All volunteers require admin approval before they can teach
- **Session Supervision**: All sessions are linked to parent accounts for visibility
- **Role-Based Access Control**: Frontend and backend route protection
- **Input Validation**: Pydantic schemas validate all inputs

## 👥 User Roles

### ADMIN
- Approves volunteer accounts
- Manages all content
- Schedules and monitors sessions
- Full system access

### VOLUNTEER
- Creates skills and learning sessions
- Uploads YouTube video links
- Requires admin approval before teaching
- Manages their own content

### PARENT
- Registers and manages children's accounts
- Enrolls students in sessions
- Views all content and session information
- Monitors learning progress

## 🐳 Docker Quick Start (Recommended)

The easiest way to run the entire platform:

### Option 1: Using the start script
```bash
./start-docker.sh
```

### Option 2: Using Makefile
```bash
make dev
```

### Option 3: Manual Docker Compose
```bash
# 1. Set up environment variables
cp .env.docker .env
# Edit .env with your Clerk credentials

# 2. Start all services
docker-compose -f docker-compose.dev.yml up -d

# 3. Access the application
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# API Docs: http://localhost:8000/api/v1/docs
```

**Quick Commands:**
- View logs: `docker-compose -f docker-compose.dev.yml logs -f`
- Stop services: `docker-compose -f docker-compose.dev.yml down`
- Restart: `docker-compose -f docker-compose.dev.yml restart`

See [DOCKER.md](./DOCKER.md) for detailed Docker instructions.

## 🚀 Getting Started (Manual Setup)

### Prerequisites

- Python 3.9+
- Node.js 18+
- PostgreSQL 12+
- Clerk account (for authentication)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your configuration:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/nonprofit_learning
   CLERK_SECRET_KEY=sk_test_your_clerk_secret_key
   CLERK_PUBLISHABLE_KEY=pk_test_your_clerk_publishable_key
   CLERK_FRONTEND_API=https://your-app.clerk.accounts.dev
   ```

5. **Set up database:**
   
   **Option A: Quick Setup with SQLite (Recommended for Development)**
   ```bash
   # Run the setup script
   python setup_database.py
   # Choose option 2 for SQLite
   ```
   
   **Option B: PostgreSQL Setup**
   ```bash
   # Method 1: Use the setup script
   python setup_database.py
   # Choose option 1 for PostgreSQL
   
   # Method 2: Manual setup
   # Create database (macOS/Linux)
   createdb -U postgres nonprofit_learning
   
   # Or using psql
   psql -U postgres -c "CREATE DATABASE nonprofit_learning;"
   
   # Update .env file with your database URL:
   # DATABASE_URL=postgresql://username:password@localhost:5432/nonprofit_learning
   ```
   
   **Run migrations:**
   ```bash
   alembic upgrade head
   ```
   
   **Verify database connection:**
   ```bash
   # Check health endpoint after starting server
   curl http://localhost:8000/api/v1/health/db
   ```

6. **Start the server:**
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

   The API will be available at `http://localhost:8000`
   API documentation at `http://localhost:8000/api/v1/docs`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.local.example .env.local
   ```
   
   Edit `.env.local` with your configuration:
   ```env
   NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_your_clerk_publishable_key
   CLERK_SECRET_KEY=sk_test_your_clerk_secret_key
   NEXT_PUBLIC_API_URL=http://localhost:8000
   NEXT_PUBLIC_CLERK_FRONTEND_API=https://your-app.clerk.accounts.dev
   ```

4. **Start the development server:**
   ```bash
   npm run dev
   ```

   The application will be available at `http://localhost:3000`

## 📝 API Endpoints

### Health Check
- `GET /health` - Health check endpoint
- `GET /api/v1/health` - API health check

### Users
- `POST /api/v1/users/register` - Register a new user
- `GET /api/v1/users/me` - Get current user
- `GET /api/v1/users` - Get all users (admin only)
- `GET /api/v1/users/pending-volunteers` - Get pending volunteers (admin only)
- `PATCH /api/v1/users/{user_id}/approve` - Approve volunteer (admin only)

### Parents
- `POST /api/v1/users/parents/register` - Register as parent
- `GET /api/v1/users/parents/me` - Get current parent info

### Students
- `POST /api/v1/users/students` - Create student
- `GET /api/v1/users/students` - Get all students for parent
- `GET /api/v1/users/students/{id}` - Get student by ID
- `PATCH /api/v1/users/students/{id}` - Update student

### Skills
- `POST /api/v1/skills` - Create skill (volunteer/admin)
- `GET /api/v1/skills` - Get all skills
- `GET /api/v1/skills/{id}` - Get skill by ID
- `PATCH /api/v1/skills/{id}` - Update skill
- `DELETE /api/v1/skills/{id}` - Delete skill

### Sessions
- `POST /api/v1/sessions` - Create session (volunteer/admin)
- `GET /api/v1/sessions` - Get all sessions
- `GET /api/v1/sessions/my-sessions` - Get volunteer's sessions
- `GET /api/v1/sessions/{id}` - Get session by ID
- `PATCH /api/v1/sessions/{id}` - Update session
- `DELETE /api/v1/sessions/{id}` - Delete session
- `POST /api/v1/sessions/enroll` - Enroll student in session
- `GET /api/v1/sessions/students/{id}/enrollments` - Get student enrollments

### Videos
- `POST /api/v1/videos` - Create video entry (volunteer/admin)
- `GET /api/v1/videos` - Get all videos
- `GET /api/v1/videos/skill/{id}` - Get videos by skill
- `GET /api/v1/videos/{id}` - Get video by ID
- `PATCH /api/v1/videos/{id}` - Update video
- `DELETE /api/v1/videos/{id}` - Delete video

## 🗄️ Database Models

- **User**: Base user with role and approval status
- **Parent**: Parent account with email
- **Student**: Student account linked to parent
- **Skill**: Learning skill/topic
- **Session**: Scheduled learning session
- **Video**: YouTube video URL entry
- **SessionEnrollment**: Student-session enrollment relationship

## 🧪 Testing

### Backend
```bash
cd backend
pytest  # If tests are added
```

### Frontend
```bash
cd frontend
npm test  # If tests are added
```

## 🚢 Deployment

### AWS Deployment with GitHub Actions

The platform includes automated CI/CD pipelines for AWS deployment:

#### Quick Setup

1. **Set up AWS Infrastructure:**
   - See [AWS Deployment Guide](./aws/README.md) for detailed instructions
   - Or use Terraform: `cd aws/terraform && terraform apply`

2. **Configure GitHub Secrets:**
   - See [GitHub Setup Guide](./GITHUB_SETUP.md) for complete instructions
   - Required secrets: AWS credentials, DATABASE_URL, Clerk keys, etc.

3. **Deploy:**
   - Push to `main` branch → Automatic deployment
   - Or manually trigger: Actions → Full Deployment to AWS

#### Deployment Architecture

- **Backend**: AWS App Runner (containerized FastAPI)
- **Frontend**: AWS S3 + CloudFront (or AWS Amplify)
- **Database**: AWS RDS PostgreSQL
- **Container Registry**: Amazon ECR

#### GitHub Actions Workflows

- **CI** (`.github/workflows/ci.yml`): Runs tests on push/PR
- **Deploy Backend** (`.github/workflows/deploy-backend.yml`): Deploys to App Runner
- **Deploy Frontend** (`.github/workflows/deploy-frontend.yml`): Deploys to S3/CloudFront
- **Deploy Database** (`.github/workflows/deploy-database.yml`): Runs migrations
- **Full Deploy** (`.github/workflows/full-deploy.yml`): Orchestrates all deployments

See [GITHUB_SETUP.md](./GITHUB_SETUP.md) and [aws/README.md](./aws/README.md) for detailed deployment instructions.

### Manual Deployment

#### Backend (AWS App Runner)

1. Build Docker image: `docker build -t nonprofit-learning-backend ./backend`
2. Push to ECR: `docker push YOUR_ECR_URI:latest`
3. Create/update App Runner service with environment variables
4. Connect to RDS PostgreSQL instance

#### Frontend (AWS S3 + CloudFront)

1. Build: `cd frontend && npm run build`
2. Deploy to S3: `aws s3 sync .next/standalone/. s3://your-bucket/`
3. Invalidate CloudFront: `aws cloudfront create-invalidation --distribution-id YOUR_ID --paths "/*"`

#### Database (AWS RDS)

1. Create PostgreSQL RDS instance
2. Update `DATABASE_URL` in backend environment
3. Run migrations: `alembic upgrade head`

## 📚 Documentation

- API Documentation: Available at `/api/v1/docs` when backend is running
- Frontend: Built with Next.js 14 App Router
- Backend: FastAPI with automatic OpenAPI documentation

## 🔧 Development

### Creating Database Migrations

```bash
cd backend
alembic revision --autogenerate -m "Description of changes"
alembic upgrade head
```

### Adding New Features

1. Backend: Add models → schemas → services → routers
2. Frontend: Add types → API functions → pages/components
3. Update documentation

## 📄 License

This project is designed for nonprofit educational purposes.

## 🤝 Contributing

This is a production-grade template. Customize as needed for your specific nonprofit organization.

## ⚠️ Important Notes

- **No Raw Video Uploads**: Only YouTube URLs are stored
- **Clerk Integration**: Authentication is handled by Clerk
- **Parent Email Required**: Critical for student safety
- **Admin Approval**: All volunteers must be approved
- **No Direct Messaging**: Communication is session-based only
