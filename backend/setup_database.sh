#!/bin/bash

# Database Setup Script for Nonprofit Learning Platform
# This script helps set up PostgreSQL database

echo "🚀 Setting up database for Nonprofit Learning Platform..."

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed."
    echo "📦 Please install PostgreSQL:"
    echo "   macOS: brew install postgresql@14"
    echo "   Ubuntu: sudo apt-get install postgresql postgresql-contrib"
    echo "   Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

echo "✅ PostgreSQL is installed"

# Get database credentials
read -p "Enter PostgreSQL username (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -sp "Enter PostgreSQL password: " DB_PASSWORD
echo ""

read -p "Enter database name (default: nonprofit_learning): " DB_NAME
DB_NAME=${DB_NAME:-nonprofit_learning}

read -p "Enter host (default: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Enter port (default: 5432): " DB_PORT
DB_PORT=${DB_PORT:-5432}

# Try to create database
echo "📦 Creating database '$DB_NAME'..."

# Export password for psql
export PGPASSWORD=$DB_PASSWORD

# Check if database exists
if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "⚠️  Database '$DB_NAME' already exists."
    read -p "Do you want to drop and recreate it? (y/N): " RECREATE
    if [[ $RECREATE =~ ^[Yy]$ ]]; then
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "DROP DATABASE $DB_NAME;"
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;"
        echo "✅ Database recreated successfully"
    else
        echo "✅ Using existing database"
    fi
else
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;"
    if [ $? -eq 0 ]; then
        echo "✅ Database created successfully"
    else
        echo "❌ Failed to create database"
        echo "💡 Try running: sudo -u postgres createdb $DB_NAME"
        exit 1
    fi
fi

# Update .env file
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    cp env.example .env
    echo "✅ Created .env file from template"
fi

# Update DATABASE_URL in .env
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

# Use sed to update DATABASE_URL (works on macOS and Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
else
    # Linux
    sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
fi

echo "✅ Updated DATABASE_URL in .env file"
echo ""
echo "🎉 Database setup complete!"
echo ""
echo "Next steps:"
echo "1. Run migrations: alembic upgrade head"
echo "2. Start the server: uvicorn app.main:app --reload --port 8000"
