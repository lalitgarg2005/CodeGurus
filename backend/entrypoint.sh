#!/bin/bash
# Don't exit on error - allow app to start even if DB check fails
set +e

echo "🚀 Starting Nonprofit Learning Platform Backend..."

# Extract database connection details from DATABASE_URL if provided
if [ -n "$DATABASE_URL" ]; then
  # Parse DATABASE_URL: postgresql://user:password@host:port/dbname
  DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
  DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
  DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
fi

# Default values
DB_HOST=${DB_HOST:-postgres}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}

# Wait for database to be ready (but don't fail if it's not)
echo "⏳ Checking database connection..."
max_attempts=15  # Reduced attempts for faster startup
attempt=0
DB_READY=false

until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" > /dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "⚠️  Database not reachable after $max_attempts attempts"
    echo "   App will start anyway - database connection will be retried by the application"
    DB_READY=false
    break
  fi
  echo "   Database check (attempt $attempt/$max_attempts)..."
  sleep 2
done

if [ "$attempt" -lt "$max_attempts" ]; then
  echo "✅ Database is reachable!"
  DB_READY=true
  
  # Run migrations only if database is reachable
  echo "📦 Running database migrations..."
  alembic upgrade head || {
    echo "⚠️  Migration failed - app will continue (migrations can be run manually)"
  }
else
  echo "⚠️  Skipping migrations - database not reachable"
  echo "   Migrations can be run manually once database is accessible"
fi

echo "🎉 Starting FastAPI server..."
# Execute any command passed (useful for --reload flag in dev)
# Re-enable exit on error for the actual application
set -e
exec "$@"
