# Database Setup Guide

This guide will help you set up the database for the Nonprofit Learning Platform.

## Quick Start (SQLite - Recommended for Development)

SQLite is the easiest option for development and doesn't require any additional setup:

```bash
cd backend
python setup_database.py
# Choose option 2 for SQLite
```

This will:
- Create a SQLite database file (`nonprofit_learning.db`)
- Update your `.env` file
- Run migrations automatically

## PostgreSQL Setup (Production)

### Prerequisites

1. **Install PostgreSQL:**
   - **macOS**: `brew install postgresql@14`
   - **Ubuntu/Debian**: `sudo apt-get install postgresql postgresql-contrib`
   - **Windows**: Download from [postgresql.org](https://www.postgresql.org/download/)

2. **Start PostgreSQL service:**
   - **macOS**: `brew services start postgresql@14`
   - **Linux**: `sudo systemctl start postgresql`
   - **Windows**: PostgreSQL service should start automatically

### Setup Methods

#### Method 1: Automated Script (Recommended)

```bash
cd backend
python setup_database.py
# Choose option 1 for PostgreSQL
# Enter your PostgreSQL credentials when prompted
```

#### Method 2: Manual Setup

1. **Create database using psql:**
   ```bash
   psql -U postgres
   CREATE DATABASE nonprofit_learning;
   \q
   ```

2. **Or using createdb command:**
   ```bash
   createdb -U postgres nonprofit_learning
   ```

3. **Update `.env` file:**
   ```env
   DATABASE_URL=postgresql://username:password@localhost:5432/nonprofit_learning
   ```

4. **Run migrations:**
   ```bash
   alembic upgrade head
   ```

#### Method 3: Using Shell Script

```bash
cd backend
chmod +x setup_database.sh
./setup_database.sh
```

## Verify Database Connection

After setting up, verify the connection:

1. **Start the server:**
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

2. **Check database health:**
   ```bash
   curl http://localhost:8000/api/v1/health/db
   ```

   You should see:
   ```json
   {
     "status": "healthy",
     "database": "connected",
     "database_url": "..."
   }
   ```

## Troubleshooting

### Issue: `createdb: command not found`

**Solution:**
- Make sure PostgreSQL is installed and in your PATH
- Try using `psql` instead:
  ```bash
  psql -U postgres -c "CREATE DATABASE nonprofit_learning;"
  ```

### Issue: `FATAL: password authentication failed`

**Solution:**
- Check your PostgreSQL username and password
- For local development, you might need to set up a password:
  ```bash
  psql -U postgres
  ALTER USER postgres PASSWORD 'your_password';
  ```

### Issue: `database "nonprofit_learning" already exists`

**Solution:**
- The database already exists, which is fine
- Just run migrations: `alembic upgrade head`
- Or drop and recreate if needed:
  ```bash
  dropdb -U postgres nonprofit_learning
  createdb -U postgres nonprofit_learning
  ```

### Issue: Connection refused

**Solution:**
- Make sure PostgreSQL is running:
  - **macOS**: `brew services list` (check if postgresql is started)
  - **Linux**: `sudo systemctl status postgresql`
- Check if the port is correct (default: 5432)

### Issue: SQLite database locked

**Solution:**
- Make sure only one instance of the application is running
- Close any database viewers that might have the file open
- Restart the server

## Switching Between Databases

To switch from SQLite to PostgreSQL (or vice versa):

1. Update `DATABASE_URL` in `.env`:
   ```env
   # For SQLite
   DATABASE_URL=sqlite:///./nonprofit_learning.db
   
   # For PostgreSQL
   DATABASE_URL=postgresql://user:password@localhost:5432/nonprofit_learning
   ```

2. Run migrations:
   ```bash
   alembic upgrade head
   ```

## Production Deployment

For production (AWS RDS, etc.):

1. Create your RDS PostgreSQL instance
2. Update `DATABASE_URL` in your environment variables:
   ```env
   DATABASE_URL=postgresql://username:password@your-rds-endpoint.rds.amazonaws.com:5432/nonprofit_learning
   ```
3. Run migrations on your production server:
   ```bash
   alembic upgrade head
   ```

## Need Help?

If you're still having issues:
1. Check the server logs for detailed error messages
2. Verify your `.env` file has the correct `DATABASE_URL`
3. Test the connection using the health check endpoint
4. Make sure all migrations have been run
