# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

Today I applied all the concepts from Days 16–18 to create real-world automation scripts for log rotation, server backup, and scheduled maintenance using crontab.

---

## ✅ Scripts and Sample Outputs

---

### 1. `log_rotate.sh`

**Purpose**: Compress `.log` files older than 7 days, delete `.gz` files older than 30 days.

**Code:**
```bash
#!/bin/bash
set -euo pipefail

LOG_DIR="${1:-}"

if [ -z "$LOG_DIR" ] || [ ! -d "$LOG_DIR" ]; then
  echo "Usage: $0 /path/to/log-directory"
  exit 1
fi

echo "Running log rotation in: $LOG_DIR"

COMPRESSED_COUNT=$(find "$LOG_DIR" -name "*.log" -mtime +7 -print -exec gzip {} \; | wc -l)
DELETED_COUNT=$(find "$LOG_DIR" -name "*.gz" -mtime +30 -print -exec rm {} \; | wc -l)

echo "Compressed $COMPRESSED_COUNT .log files older than 7 days"
echo "Deleted $DELETED_COUNT .gz files older than 30 days"
Sample Output:

Running log rotation in: /home/iamhamster/logs_test
Compressed 2 .log files older than 7 days
Deleted 0 .gz files older than 30 days
2. backup.sh
Purpose: Archive a source directory and clean up old backups.

Code:

#!/bin/bash
set -euo pipefail

SRC="${1:-}"
DEST="${2:-}"

if [ -z "$SRC" ] || [ -z "$DEST" ]; then
  echo "Usage: $0 /path/to/source /path/to/backup-destination"
  exit 1
fi

if [ ! -d "$SRC" ]; then
  echo "Source directory does not exist: $SRC"
  exit 1
fi

DATE=$(date +%Y-%m-%d)
BACKUP_NAME="backup-$DATE.tar.gz"
BACKUP_PATH="$DEST/$BACKUP_NAME"

tar -czf "$BACKUP_PATH" "$SRC"

if [ -f "$BACKUP_PATH" ]; then
  SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
  echo "✅ Backup created: $BACKUP_NAME"
  echo "📦 Size: $SIZE"
else
  echo "❌ Backup failed."
  exit 1
fi

OLD_BACKUPS=$(find "$DEST" -name "backup-*.tar.gz" -mtime +14 -print -exec rm {} \;)
echo "Old backups deleted:"
echo "$OLD_BACKUPS"
Sample Output:

✅ Backup created: backup-2026-02-13.tar.gz
📦 Size: 4.1M
Old backups deleted:
3. maintenance.sh
Purpose: Combine log rotation and backup; log the process with timestamps.

Code:

#!/bin/bash
set -euo pipefail

LOG_FILE=~/maintenance.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "=== Starting Maintenance ==="

if ./log_rotate.sh ~/logs_test >> "$LOG_FILE" 2>&1; then
  log " Log rotation successful"
else
  log " Log rotation failed"
fi

if ./backup.sh ~/projects ~/backups >> "$LOG_FILE" 2>&1; then
  log " Backup successful"
else
  log " Backup failed"
fi

log "=== Maintenance Completed ==="