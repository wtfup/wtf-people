#!/bin/bash

set -e

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
    exit 0
fi

echo "=========================================="
echo "  Creating new Frappe bench for HRMS..."
echo "=========================================="

# Set node path
export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

# Initialize bench
bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Configure to use containers instead of localhost
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

# Remove redis and watch from Procfile (handled by containers)
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

echo ""
echo "Getting ERPNext app..."
bench get-app erpnext

echo ""
echo "Getting HRMS app..."
bench get-app hrms

echo ""
echo "Creating site hrms.localhost..."
bench new-site hrms.localhost \
    --force \
    --mariadb-root-password 123 \
    --admin-password admin \
    --no-mariadb-socket

echo ""
echo "Installing HRMS on site..."
bench --site hrms.localhost install-app hrms

echo ""
echo "Configuring site..."
bench --site hrms.localhost set-config developer_mode 1
bench --site hrms.localhost enable-scheduler
bench --site hrms.localhost clear-cache
bench use hrms.localhost

echo ""
echo "=========================================="
echo "  HRMS Setup Complete!"
echo "=========================================="
echo ""
echo "Access at: http://localhost:8080"
echo "Username:  Administrator"
echo "Password:  admin"
echo ""

# Start the bench
bench start
