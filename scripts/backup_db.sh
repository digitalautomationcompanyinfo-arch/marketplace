#!/bin/bash
# ─── Marketplace DB Backup Script ────────────────────────
# يحفظ نسخة من قاعدة البيانات يومياً مع تدوير النسخ (7 أيام)

# Configuration
BACKUP_DIR="./backups"
DB_CONTAINER="marketplace_db"  # تأكد من تطابق الاسم في docker-compose
DB_USER="postgres"
DB_NAME="marketplace_db"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="backup_${DB_NAME}_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "🚀 Starting backup: $FILENAME ..."

# Perform backup using docker exec
docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_DIR/$FILENAME"

if [ $? -eq 0 ]; then
    echo "✅ Backup successful: $BACKUP_DIR/$FILENAME"
    
    # Compress the backup to save space
    gzip "$BACKUP_DIR/$FILENAME"
    
    # Rotate: Delete backups older than 7 days
    find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +7 -delete
    echo "🧹 Rotated old backups (older than 7 days)."
else
    echo "❌ Backup failed! Please check if the container '$DB_CONTAINER' is running."
    exit 1
fi
