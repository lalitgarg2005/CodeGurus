# PostgreSQL Installation & Setup Guide

This guide will help you install and set up PostgreSQL on macOS.

## Installation Methods

### Method 1: Homebrew (Recommended for macOS)

1. **Install Homebrew** (if you don't have it):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install PostgreSQL:**
   ```bash
   brew install postgresql@14
   ```

3. **Start PostgreSQL service:**
   ```bash
   brew services start postgresql@14
   ```

4. **Verify installation:**
   ```bash
   psql --version
   ```

### Method 2: Postgres.app (GUI Application)

1. **Download Postgres.app:**
   - Visit: https://postgresapp.com/
   - Download and install the app

2. **Start the app:**
   - Open Postgres.app from Applications
   - Click "Initialize" to create a new server

3. **Add to PATH:**
   ```bash
   sudo mkdir -p /etc/paths.d &&
   echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
   ```

### Method 3: Official Installer

1. **Download from PostgreSQL website:**
   - Visit: https://www.postgresql.org/download/macosx/
   - Download the installer

2. **Run the installer:**
   - Follow the installation wizard
   - Remember the password you set for the `postgres` user

## Initial Setup

### 1. Set up PostgreSQL user and password

```bash
# Connect to PostgreSQL
psql postgres

# Set password for postgres user (replace 'yourpassword' with your desired password)
ALTER USER postgres PASSWORD 'yourpassword';

# Create a new user for development (optional but recommended)
CREATE USER nonprofit_user WITH PASSWORD 'yourpassword';

# Grant privileges
ALTER USER nonprofit_user CREATEDB;

# Exit psql
\q
```

### 2. Create the database

```bash
# Using createdb command
createdb -U postgres nonprofit_learning

# Or using psql
psql -U postgres -c "CREATE DATABASE nonprofit_learning;"
```

### 3. Update your .env file

```bash
cd backend
```

Edit `.env` file (or create from `env.example`):
```env
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/nonprofit_learning
```

Replace `yourpassword` with the password you set.

### 4. Run migrations

```bash
alembic upgrade head
```

## Troubleshooting

### Issue: `psql: command not found`

**Solution:**
- Add PostgreSQL to your PATH:
  ```bash
  # For Homebrew installation
  echo 'export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  
  # Or for older Macs with Intel
  echo 'export PATH="/usr/local/opt/postgresql@14/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  ```

### Issue: `FATAL: password authentication failed`

**Solution:**
- Reset the postgres user password:
  ```bash
  psql postgres
  ALTER USER postgres PASSWORD 'newpassword';
  \q
  ```
- Update your `.env` file with the new password

### Issue: `FATAL: database "nonprofit_learning" does not exist`

**Solution:**
- Create the database:
  ```bash
  createdb -U postgres nonprofit_learning
  ```

### Issue: PostgreSQL service not running

**Solution:**
- Start the service:
  ```bash
  # For Homebrew
  brew services start postgresql@14
  
  # Check status
  brew services list
  ```

### Issue: Port 5432 already in use

**Solution:**
- Check what's using the port:
  ```bash
  lsof -i :5432
  ```
- Stop the conflicting service or use a different port

## Quick Verification

After setup, verify everything works:

```bash
# Test connection
psql -U postgres -d nonprofit_learning -c "SELECT version();"

# Check if tables exist (after running migrations)
psql -U postgres -d nonprofit_learning -c "\dt"
```

## Next Steps

Once PostgreSQL is set up:

1. **Update .env file** with your database URL
2. **Run migrations**: `alembic upgrade head`
3. **Start the server**: `uvicorn app.main:app --reload --port 8000`
4. **Test the API**: Visit `http://localhost:8000/api/v1/docs`

## Alternative: Use SQLite (No Installation Needed)

If you want to skip PostgreSQL installation for now, you can use SQLite:

```bash
cd backend
python setup_database.py
# Choose option 2 for SQLite
```

This requires no additional installation and works immediately!
