#!/bin/bash
# WTF People HRMS - Automated Backup Script

set -e

BACKUP_DIR="/home/wtfadmin/backups"
DATE=$(date +%Y%m%d_%H%M%S)
SITE_NAME="${SITE_NAME:-people.wtfgyms.com}"

# Load environment variables
if [ -f /home/wtfadmin/wtf-people/docker/.env.prod ]; then
    source /home/wtfadmin/wtf-people/docker/.env.prod
fi

mkdir -p $BACKUP_DIR

echo "[$DATE] Starting backup..."

# Database backup
echo "Backing up database..."
docker exec wtf-people-mariadb-1 mysqldump -u root -p"${DB_ROOT_PASSWORD}" --all-databases > $BACKUP_DIR/db_$DATE.sql

# Sites backup via Frappe
echo "Backing up Frappe site..."
docker exec wtf-people-backend-1 bench --site $SITE_NAME backup --with-files

# Copy site backup files to backup directory
docker cp wtf-people-backend-1:/home/frappe/frappe-bench/sites/$SITE_NAME/private/backups/. $BACKUP_DIR/site_$DATE/

# Compress
echo "Compressing backups..."
gzip $BACKUP_DIR/db_$DATE.sql
tar -czf $BACKUP_DIR/site_$DATE.tar.gz -C $BACKUP_DIR site_$DATE
rm -rf $BACKUP_DIR/site_$DATE

# Keep only last 7 days
echo "Cleaning old backups..."
find $BACKUP_DIR -type f -mtime +7 -delete

echo "[$DATE] Backup completed successfully!"
echo "Files:"
ls -lh $BACKUP_DIR | tail -5
