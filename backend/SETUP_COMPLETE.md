# ✅ PostgreSQL Setup Complete!

Your PostgreSQL database has been successfully installed and configured!

## What Was Done

1. ✅ PostgreSQL 14.20 installed via Homebrew
2. ✅ PostgreSQL service started and running
3. ✅ Database `nonprofit_learning` created
4. ✅ Database migrations run successfully
5. ✅ All tables created in the database

## Database Connection Details

- **Host**: localhost
- **Port**: 5432
- **Database**: nonprofit_learning
- **Username**: Lalit_Garg (your macOS username)
- **Password**: Not required for local connections

## Next Steps

### 1. Verify Database Tables

You can check that all tables were created:

```bash
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
psql -U Lalit_Garg -d nonprofit_learning -c "\dt"
```

You should see these tables:
- users
- parents
- students
- skills
- sessions
- session_enrollments
- videos

### 2. Start the Backend Server

```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

### 3. Test the Database Connection

In another terminal, test the health endpoint:

```bash
curl http://localhost:8000/api/v1/health/db
```

You should see:
```json
{
  "status": "healthy",
  "database": "connected",
  "database_url": "localhost:5432/nonprofit_learning"
}
```

### 4. Test Registration

Now you can test the Volunteer and Parent registration:
- Visit: http://localhost:3000 (frontend)
- Sign up with Clerk
- Try registering as a Volunteer or Parent
- It should work now! 🎉

## Useful PostgreSQL Commands

```bash
# Connect to database
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
psql -U Lalit_Garg -d nonprofit_learning

# List all databases
psql -U Lalit_Garg -d postgres -c "\l"

# List all tables
psql -U Lalit_Garg -d nonprofit_learning -c "\dt"

# View table structure
psql -U Lalit_Garg -d nonprofit_learning -c "\d users"

# Stop PostgreSQL service
brew services stop postgresql@14

# Start PostgreSQL service
brew services start postgresql@14
```

## Troubleshooting

### If you need to reset the database:

```bash
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
dropdb -U Lalit_Garg nonprofit_learning
createdb -U Lalit_Garg nonprofit_learning
cd backend
alembic upgrade head
```

### If PostgreSQL service stops:

```bash
brew services start postgresql@14
```

### To check PostgreSQL status:

```bash
brew services list | grep postgresql
```

## Your .env File

Your `.env` file has been updated with:
```
DATABASE_URL=postgresql://Lalit_Garg@localhost:5432/nonprofit_learning
```

Make sure you also have your Clerk credentials set in the `.env` file:
- CLERK_SECRET_KEY
- CLERK_PUBLISHABLE_KEY
- CLERK_FRONTEND_API

## 🎉 You're All Set!

Your PostgreSQL database is now set up and ready to use. The registration endpoints should work perfectly now!
