#!/bin/bash
# WTF People HRMS - Deployment Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=========================================="
echo "WTF People HRMS - Deployment"
echo "=========================================="

# Check if .env.prod exists
if [ ! -f "$DOCKER_DIR/.env.prod" ]; then
    echo "ERROR: $DOCKER_DIR/.env.prod not found!"
    echo "Please copy .env.prod.example to .env.prod and configure it."
    exit 1
fi

# Load environment variables
source "$DOCKER_DIR/.env.prod"

echo "Site: $SITE_NAME"
echo "ERPNext Version: $ERPNEXT_VERSION"
echo ""

cd "$DOCKER_DIR"

case "${1:-deploy}" in
    deploy)
        echo "Starting deployment..."

        # Pull latest images
        echo "[1/4] Pulling latest images..."
        docker compose -f docker-compose.prod.yml pull

        # Start infrastructure services
        echo "[2/4] Starting infrastructure services..."
        docker compose -f docker-compose.prod.yml up -d mariadb redis-cache redis-queue
        echo "Waiting for MariaDB to be ready..."
        sleep 30

        # Check if site exists
        if docker compose -f docker-compose.prod.yml run --rm backend bench --site $SITE_NAME list-apps 2>/dev/null; then
            echo "Site already exists, starting services..."
        else
            echo "[3/4] Creating new site..."
            docker compose -f docker-compose.prod.yml run --rm backend \
                bench new-site $SITE_NAME \
                --mariadb-root-password "$DB_ROOT_PASSWORD" \
                --admin-password "$ADMIN_PASSWORD" \
                --install-app erpnext \
                --install-app hrms
        fi

        # Start all services
        echo "[4/4] Starting all services..."
        docker compose -f docker-compose.prod.yml up -d

        echo ""
        echo "Deployment complete!"
        echo "Site will be available at: https://$SITE_NAME"
        echo "(Note: SSL certificate may take a minute to provision)"
        ;;

    stop)
        echo "Stopping all services..."
        docker compose -f docker-compose.prod.yml down
        echo "Services stopped."
        ;;

    restart)
        echo "Restarting all services..."
        docker compose -f docker-compose.prod.yml restart
        echo "Services restarted."
        ;;

    logs)
        docker compose -f docker-compose.prod.yml logs -f ${2:-}
        ;;

    status)
        docker compose -f docker-compose.prod.yml ps
        ;;

    backup)
        echo "Running backup..."
        "$SCRIPT_DIR/backup.sh"
        ;;

    update)
        echo "Updating application..."
        docker compose -f docker-compose.prod.yml pull
        docker compose -f docker-compose.prod.yml up -d
        echo "Update complete!"
        ;;

    *)
        echo "Usage: $0 {deploy|stop|restart|logs|status|backup|update}"
        echo ""
        echo "Commands:"
        echo "  deploy  - Deploy/start the application"
        echo "  stop    - Stop all services"
        echo "  restart - Restart all services"
        echo "  logs    - View logs (optionally specify service)"
        echo "  status  - Show service status"
        echo "  backup  - Run backup"
        echo "  update  - Update to latest images"
        exit 1
        ;;
esac
