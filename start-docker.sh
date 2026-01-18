#!/bin/bash

# Quick start script for Docker setup

echo "🐳 Starting Nonprofit Learning Platform with Docker..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    if [ -f .env.docker ]; then
        cp .env.docker .env
        echo "✅ Created .env file"
        echo "⚠️  Please edit .env and add your Clerk credentials before continuing!"
        echo ""
        read -p "Press Enter after you've updated .env with your Clerk keys..."
    else
        echo "❌ .env.docker template not found"
        exit 1
    fi
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

echo "🚀 Starting services in development mode..."
echo ""

# Use docker-compose or docker compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

$COMPOSE_CMD -f docker-compose.dev.yml up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 5

echo ""
echo "✅ Services started!"
echo ""
echo "📍 Access your application:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:8000"
echo "   API Docs:  http://localhost:8000/api/v1/docs"
echo ""
echo "📊 View logs:"
echo "   $COMPOSE_CMD -f docker-compose.dev.yml logs -f"
echo ""
echo "🛑 Stop services:"
echo "   $COMPOSE_CMD -f docker-compose.dev.yml down"
echo ""
