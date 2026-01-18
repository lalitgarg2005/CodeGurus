.PHONY: help build up down logs restart clean dev prod

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build all Docker images
	docker-compose -f docker-compose.dev.yml build

up: ## Start all services (development)
	docker-compose -f docker-compose.dev.yml up -d

down: ## Stop all services
	docker-compose -f docker-compose.dev.yml down

logs: ## View logs from all services
	docker-compose -f docker-compose.dev.yml logs -f

logs-backend: ## View backend logs
	docker-compose -f docker-compose.dev.yml logs -f backend

logs-frontend: ## View frontend logs
	docker-compose -f docker-compose.dev.yml logs -f frontend

logs-db: ## View database logs
	docker-compose -f docker-compose.dev.yml logs -f postgres

restart: ## Restart all services
	docker-compose -f docker-compose.dev.yml restart

restart-backend: ## Restart backend service
	docker-compose -f docker-compose.dev.yml restart backend

restart-frontend: ## Restart frontend service
	docker-compose -f docker-compose.dev.yml restart frontend

clean: ## Remove all containers, networks, and volumes
	docker-compose -f docker-compose.dev.yml down -v

dev: build up ## Build and start in development mode
	@echo "✅ Services started!"
	@echo "Frontend: http://localhost:3000"
	@echo "Backend: http://localhost:8000"
	@echo "API Docs: http://localhost:8000/api/v1/docs"

prod: ## Start in production mode
	docker-compose -f docker-compose.prod.yml up -d
	@echo "✅ Production services started!"

prod-build: ## Build production images
	docker-compose -f docker-compose.prod.yml build

prod-down: ## Stop production services
	docker-compose -f docker-compose.prod.yml down

migrate: ## Run database migrations
	docker-compose -f docker-compose.dev.yml exec backend alembic upgrade head

shell-backend: ## Open shell in backend container
	docker-compose -f docker-compose.dev.yml exec backend bash

shell-frontend: ## Open shell in frontend container
	docker-compose -f docker-compose.dev.yml exec frontend sh

shell-db: ## Open PostgreSQL shell
	docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d nonprofit_learning

status: ## Show status of all services
	docker-compose -f docker-compose.dev.yml ps
