#!/bin/bash
# WTF People HRMS - Company Setup Script
# Run this after initial deployment to set up WTF company structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

# Load environment variables
source "$DOCKER_DIR/.env.prod"

echo "=========================================="
echo "WTF People - Company Setup"
echo "=========================================="

cd "$DOCKER_DIR"

# Copy setup script to container
echo "Copying setup script..."
docker cp "$SCRIPT_DIR/../setup_company.py" wtf-people-backend-1:/tmp/setup_company.py

# Copy logo
echo "Copying logo..."
docker cp "$PROJECT_DIR/wtf-logo.png" wtf-people-backend-1:/home/frappe/frappe-bench/sites/$SITE_NAME/public/files/wtf-logo.png

# Run setup script
echo "Running company setup..."
docker exec wtf-people-backend-1 bench --site $SITE_NAME execute /tmp/setup_company.py

# Apply branding via bench commands
echo "Applying branding..."
docker exec wtf-people-backend-1 bench --site $SITE_NAME set-config app_name "WTF People"

# Clear cache
echo "Clearing cache..."
docker exec wtf-people-backend-1 bench --site $SITE_NAME clear-cache

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo "Login at: https://$SITE_NAME"
echo "Username: Administrator"
echo "Password: (as configured in .env.prod)"
