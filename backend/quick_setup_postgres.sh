#!/bin/bash

# Quick PostgreSQL Setup Script
# This script sets up PostgreSQL for the Nonprofit Learning Platform

export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"

echo "🚀 Setting up PostgreSQL for Nonprofit Learning Platform..."
echo ""

# Get current username
DB_USER=$(whoami)
DB_NAME="nonprofit_learning"

echo "Using:"
echo "  Username: $DB_USER"
echo "  Database: $DB_NAME"
echo "  Host: localhost"
echo "  Port: 5432"
echo ""

# Check if database exists
if psql -U $DB_USER -d postgres -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "✅ Database '$DB_NAME' already exists"
else
    echo "📦 Creating database '$DB_NAME'..."
    createdb -U $DB_USER $DB_NAME
    if [ $? -eq 0 ]; then
        echo "✅ Database created successfully"
    else
        echo "❌ Failed to create database"
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
# For macOS, use the current user (no password needed for local connections)
DATABASE_URL="postgresql://$DB_USER@localhost:5432/$DB_NAME"

# Use sed to update DATABASE_URL
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if grep -q "DATABASE_URL=" .env; then
        sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
    else
        echo "DATABASE_URL=$DATABASE_URL" >> .env
    fi
else
    # Linux
    if grep -q "DATABASE_URL=" .env; then
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
    else
        echo "DATABASE_URL=$DATABASE_URL" >> .env
    fi
fi

echo "✅ Updated DATABASE_URL in .env file"
echo ""
echo "📦 Running database migrations..."
alembic upgrade head

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 PostgreSQL setup complete!"
    echo ""
    echo "Your database is ready. You can now:"
    echo "1. Start the server: uvicorn app.main:app --reload --port 8000"
    echo "2. Test the API: curl http://localhost:8000/api/v1/health/db"
else
    echo ""
    echo "⚠️  Migrations completed with warnings. Check the output above."
fi
