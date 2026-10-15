#!/usr/bin/env bash
# Snapshot everything that cannot be re-downloaded: the worlds and the player lists.
# Usage: ./valheim backup      (or scripts/backup.sh)
#   BACKUP_DIR      where tarballs go            (default ./backups)
#   RETENTION_DAYS  delete tarballs older than   (default 14)
set -euo pipefail

cd "$(dirname "$0")/.."

BACKUP_DIR=${BACKUP_DIR:-./backups}
RETENTION_DAYS=${RETENTION_DAYS:-14}
TIMESTAMP=$(date +%F-%H%M)
ARCHIVE="$BACKUP_DIR/valheim-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

if [ ! -d config/worlds_local ]; then
    echo "[backup] config/worlds_local not found, nothing to back up (has the server started once?)"
    exit 1
fi

# The game files in ./data and the image itself are reproducible and intentionally excluded.
ITEMS=(config/worlds_local)
for f in config/adminlist.txt config/bannedlist.txt config/permittedlist.txt; do
    if [ -f "$f" ]; then ITEMS+=("$f"); fi
done

echo "[backup] Creating $ARCHIVE"
if ! tar --warning=no-file-changed -czf "$ARCHIVE" "${ITEMS[@]}"; then
    echo "[backup] ERROR: tar failed. If ./config is root-owned (lloesche image or PUID=0), run: sudo ./valheim backup"
    rm -f "$ARCHIVE"
    exit 1
fi
gzip -t "$ARCHIVE"

echo "[backup] Pruning archives older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -maxdepth 1 -name 'valheim-*.tar.gz' -mtime "+$RETENTION_DAYS" -delete

ls -lh "$ARCHIVE"
echo "[backup] Done"
