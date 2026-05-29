#!/usr/bin/env bash
set -Eeuo pipefail

# Adjust if your filename is spelled differently:
DB="/data/docker/chatsubo/server/evennia.db3"
BACKUP_DIR="/data/docker/chatsubo/backups/evennia"
STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="${BACKUP_DIR}/evennia-${STAMP}.db3"
LOCKFILE="/var/lock/evennia-backup.lock"

# sanity checks
if [[ ! -f "$DB" ]]; then
  echo "ERROR: DB not found at $DB" >&2
  exit 1
fi
command -v sqlite3 >/dev/null || { echo "ERROR: sqlite3 not installed"; exit 1; }

# ensure backup dir exists and is private
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# prevent overlap
exec 9>"$LOCKFILE"
if ! flock -n 9; then
  echo "Backup already running; exiting."
  exit 0
fi

# create consistent backup using SQLite online backup API
sqlite3 "$DB" ".backup '$DEST'"

# quick integrity check
if [[ "$(sqlite3 "$DEST" 'PRAGMA integrity_check;')" != "ok" ]]; then
  echo "ERROR: backup integrity check failed" >&2
  rm -f -- "$DEST"
  exit 1
fi

chmod 600 "$DEST"

# keep only the newest 10
# (will no-op cleanly if there are fewer than 10)
ls -1t "${BACKUP_DIR}"/evennia-*.db3 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "Backup complete: $DEST"

