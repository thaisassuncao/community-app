.PHONY: help build up down test shell db-setup db-migrate lint lint-fix logs clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

test: ## Run RSpec tests
	docker-compose run --rm test

test-setup: ## Setup test database
	docker-compose run --rm test bundle exec rails db:create db:migrate RAILS_ENV=test

shell: ## Open a shell in the app container
	docker-compose run --rm app sh

db-setup: ## Setup development database
	docker-compose run --rm app bundle exec rails db:create db:migrate

db-migrate: ## Run database migrations
	docker-compose run --rm app bundle exec rails db:migrate

lint: ## Run RuboCop linter
	docker-compose run --rm app bundle exec rubocop

lint-fix: ## Run RuboCop with auto-fix
	docker-compose run --rm app bundle exec rubocop -A

logs: ## Show logs
	docker-compose logs -f

clean: ## Clean up Docker resources
	docker-compose down -v
	docker system prune -f
