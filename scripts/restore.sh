#!/usr/bin/env bash
# Restore worlds and player lists from a tarball made by scripts/backup.sh.
# Usage: ./valheim restore ./backups/valheim-2026-10-15-0930.tar.gz
set -euo pipefail

cd "$(dirname "$0")/.."

ARCHIVE="${1:-}"

if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
    echo "Usage: $0 <backup-archive.tar.gz>"
    echo "Example: $0 ./backups/valheim-2026-10-15-0930.tar.gz"
    exit 1
fi

echo "[restore] This overwrites config/worlds_local and the player lists with the archive contents."
read -r -p "[restore] Continue? [y/N] " answer
case "${answer,,}" in y|yes) ;; *) echo "[restore] Aborted"; exit 1 ;; esac

echo "[restore] Stopping the server (world is saved first)"
docker compose stop valheim

echo "[restore] Extracting $ARCHIVE"
if ! tar -xzf "$ARCHIVE"; then
    echo "[restore] ERROR: extraction failed. If ./config is root-owned, run this with sudo."
    exit 1
fi

echo "[restore] Starting the server"
docker compose start valheim

echo "[restore] Done"
