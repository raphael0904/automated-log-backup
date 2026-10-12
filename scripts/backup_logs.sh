
#!/usr/bin/env bash

# Automated Log Backup System
# Elevvo Cloud & DevOps - Task 3

set -Eeuo pipefail
umask 077

# Load optional configuration from outside the Git repository.
CONFIG_FILE="${HOME}/.config/task3/backup.env"

if [[ -f "$CONFIG_FILE" ]]; then
    # Only source a configuration file you own and trust.
    source "$CONFIG_FILE"
fi

# Allow environment variables to override these defaults.
SOURCE_DIR="${SOURCE_DIR:-$HOME/devops-task3/logs}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/devops-task3/backups}"
LOG_FILE="${LOG_FILE:-$HOME/devops-task3/reports/backup.log}"

# Record events with timestamps.
mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

log_message() {
    printf '[%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$1" \
        >> "$LOG_FILE"
}

# Ensure the source directory exists.
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_message "ERROR: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Prevent overlapping executions.
exec 9>"$BACKUP_DIR/.backup.lock"

if ! flock -n 9; then
    log_message "WARNING: Another backup is already running."
    exit 0
fi

# Check whether there are files to archive.
if ! find "$SOURCE_DIR" -type f -print -quit | grep -q .; then
    log_message "WARNING: No files found; backup skipped."
    exit 0
fi

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
ARCHIVE="$BACKUP_DIR/logs_${TIMESTAMP}.tar.gz"
TEMP_ARCHIVE="${ARCHIVE}.tmp"

# Remove an incomplete temporary archive if an error occurs.
cleanup() {
    rm -f "$TEMP_ARCHIVE"
}
trap cleanup EXIT

# Create the compressed archive.
if tar -czf "$TEMP_ARCHIVE" -C "$SOURCE_DIR" .; then
    # Verify archive integrity before publishing it.
    if tar -tzf "$TEMP_ARCHIVE" >/dev/null; then
        mv "$TEMP_ARCHIVE" "$ARCHIVE"
        chmod 600 "$ARCHIVE"
        log_message "SUCCESS: Backup created: $ARCHIVE"

        # Optional bonus: notify a webhook if configured.
        if [[ -n "${WEBHOOK_URL:-}" ]]; then
            if curl --fail --silent --show-error \
                --max-time 10 \
                -X POST \
                -H 'Content-Type: text/plain' \
                --data "Log backup completed: ${ARCHIVE}" \
                "$WEBHOOK_URL" >/dev/null; then
                log_message "SUCCESS: Webhook notification sent."
            else
                log_message "WARNING: Webhook notification failed."
            fi
        fi
    else
        log_message "ERROR: Archive integrity verification failed."
        exit 1
    fi
else
    log_message "ERROR: tar failed to create the archive."
    exit 1
fi
