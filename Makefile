# Variables
EMAIL = contact@datanovia.com
DOMAIN = dev.datanovia.com
DEPLOY_SCRIPT = ./deploy.sh

# Targets
.PHONY: all deploy deploy-test stop start help

# Default target
all: help

# Help target
help:
	@echo "Makefile for deploying Træfik services"
	@echo
	@echo "Targets:"
	@echo "  deploy        Deploy services for production"
	@echo "  deploy-test   Deploy services for testing"
	@echo "  stop          Stop all running Docker Compose containers"
	@echo "  start         Start Docker Compose containers (without redeploying)"
	@echo "  help          Display this help message"
	@echo
	@echo "Variables:"
	@echo "  EMAIL         The email address for Let's Encrypt (default: contact@datanovia.com)"
	@echo "  DOMAIN        The domain name to deploy (default: dev.datanovia.com)"
	@echo

# Deployment target for production
deploy:
	@echo "Deploying production services for $(DOMAIN) using email $(EMAIL)..."
	$(DEPLOY_SCRIPT) --email $(EMAIL) --domain-name $(DOMAIN)

# Deployment target for testing
deploy-test:
	@echo "Deploying testing services for $(DOMAIN) using email $(EMAIL)..."
	$(DEPLOY_SCRIPT) --email $(EMAIL) --domain-name $(DOMAIN) --test

# Stop all running Docker Compose containers
stop:
	@echo "Stopping all running Docker Compose containers..."
	docker compose down

# Start existing Docker Compose containers
start:
	@echo "Starting Docker Compose containers..."
	docker compose up -d
