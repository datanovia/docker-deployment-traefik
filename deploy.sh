#!/bin/bash

set -euo pipefail

# Default values
ACME_EMAIL="postmaster@mydomain.com"
DOMAIN_NAME="whoami.mydomain.com"
IS_TEST=false

# Function to display help
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --email <email>         Valid email address to be used for ACME_EMAIL (default: postmaster@mydomain.com)."
    echo "  --domain-name <name>    Domain name to be used for deployment (e.g., dev.datanovia.com)."
    echo "  --test                  Deploy in testing mode (uses sample.docker-compose-test.yml)."
    echo "  --help                  Display this help message."
    echo
    echo "Example:"
    echo "  $0 --email your-email@example.com --domain-name dev.datanovia.com --test"
    echo "  $0 --email your-email@example.com --domain-name prod.datanovia.com"
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --email)
            ACME_EMAIL="$2"
            shift 2
            ;;
        --domain-name)
            DOMAIN_NAME="$2"
            shift 2
            ;;
        --test)
            IS_TEST=true
            shift
            ;;
        --help)
            display_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help to see the available options."
            exit 1
            ;;
    esac
done

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------

# Function to create a Docker network if it doesn't exist
# Usage: create_network NETWORK_NAME
create_network() {
    local NETWORK_NAME=$1
    GREEN_CHECK="$(tput setaf 2)✔$(tput sgr0)"  
    RED_CROSS="$(tput setaf 1)✖$(tput sgr0)" 

    if [ -z "$NETWORK_NAME" ]; then
        echo "$RED_CROSS Error: Network name must be provided as an argument."
        return 1
    fi
    # Check if the network exists
    # list the network names and grep to check if the network name exists
    if docker network ls --format "{{.Name}}" | grep -q "^${NETWORK_NAME}$"; then
        echo "$GREEN_CHECK Docker network '$NETWORK_NAME' already exists."
        echo "  Skipping network creation."
    else
        echo "Creating Docker network '$NETWORK_NAME'..."
        docker network create "$NETWORK_NAME"
        if [ $? -eq 0 ]; then
            echo "$GREEN_CHECK Docker network '$NETWORK_NAME' created successfully."
        else
            echo "$RED_CROSS Failed to create Docker network '$NETWORK_NAME'."
            return 1
        fi
    fi
}

# Function to check if any Docker Compose containers are running
ensure_containers_down() {
    echo "Checking for running Docker Compose containers..."
    if docker compose ps --quiet | grep -q .; then
        echo -e "$GREEN_CHECK Active containers detected. Stopping them now..."
        if docker compose down; then
            echo -e "$GREEN_CHECK Successfully stopped previous Docker Compose containers."
        else
            echo -e "$RED_CROSS Failed to stop Docker Compose containers."
            exit 1
        fi
    else
        echo -e "$GREEN_CHECK No running Docker Compose containers detected."
    fi
}

# ----------------------------------------------------------------------
# Settings
# ----------------------------------------------------------------------

# Derive DOMAIN_ID from DOMAIN_NAME by replacing dots with dashes
DOMAIN_ID=$(echo "$DOMAIN_NAME" | tr '.' '-')
NETWORK_NAME="webproxy"
echo $DOMAIN_ID


# ----------------------------------------------------------------------
# Main script
# ----------------------------------------------------------------------

# Step 1: Create an external Docker network named "webproxy"
echo "Creating Docker network 'webproxy'..."
create_network "webproxy"

# Step 2: Update permissions for 'config/acme'
echo "Updating permissions for 'config/acme'..."
if chmod go+w config/acme; then
    echo -e "$GREEN_CHECK Successfully updated permissions for 'config/acme'."
else
    echo -e "$RED_CROSS Failed to change permissions for 'config/acme'."
    exit 1
fi

# Step 3: Make copies of all `sample.` files
echo "Copying 'sample.' files..."
for file in sample.*; do
    cp "$file" "${file#sample.}" || { echo "Failed to copy $file"; exit 1; }
done

# Step 4: Determine deployment type and copy the appropriate docker-compose file
if [ "$IS_TEST" = true ]; then
    echo "Deploying in test mode. Copying test docker-compose file..."
    cp sample.docker-compose-test.yml docker-compose.yml || { echo "$RED_CROSS Failed to copy sample.docker-compose-test.yml"; exit 1; }
else
    echo "Deploying in production mode. Copying production docker-compose file..."
    cp sample.docker-compose-prod.yml docker-compose.yml || { echo "$RED_CROSS Failed to copy sample.docker-compose-prod.yml"; exit 1; }
fi

# Step 5: Update environment variables in '.env'
echo "Updating '.env' with provided email and domain ID..."
sed -i "s/postmaster@mydomain.com/$ACME_EMAIL/" .env
sed -i "s/whoami\\.mydomain\\.com/$DOMAIN_NAME/" .env
sed -i "s/whoami-mydomain-com/$DOMAIN_ID/" .env || { echo "Failed to update '.env'"; exit 1; }
echo "$GREEN_CHECK Successfully updated '.env' with provided email and domain ID."


# Step 6: Start the container
# Ensure containers are down before starting them up again
ensure_containers_down

echo "Starting containers using docker-compose.yml..."
docker compose up -d || { echo "Failed to start Docker containers"; exit 1; }

# Final Instructions
echo "$GREEN_CHECK Deployment completed!"
if [ "$IS_TEST" = true ]; then
    echo "Visit https://$DOMAIN_NAME to confirm everything is working."
fi



# ./deploy.sh --email alboukadel.kassambara@gmail.com --domain-name dev.datanovia.com --test