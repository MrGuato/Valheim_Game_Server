#!/usr/bin/env bash
# Runs as root: aligns the in-container user with PUID/PGID, fixes ownership of the
# bind-mounted volumes, applies TZ, then drops privileges and runs entrypoint.sh.
# PUID=0 keeps the server running as root.
set -euo pipefail

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
CONFIG_DIR="${CONFIG_DIR:-/config}"
SERVER_DIR="${SERVER_DIR:-/opt/valheim/server}"
STEAMCMD_DIR="${STEAMCMD_DIR:-/opt/steamcmd}"

log() { echo "[valheim] $*"; }

if [ "$(id -u)" -ne 0 ]; then
    # Container was started with --user; nothing to fix.
    exec /usr/local/bin/entrypoint.sh "$@"
fi

if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

mkdir -p "$CONFIG_DIR" "$SERVER_DIR"

if [ "$PUID" = "0" ]; then
    log "PUID=0, running the server as root"
    exec /usr/local/bin/entrypoint.sh "$@"
fi

if [ "$(id -g valheim)" != "$PGID" ]; then groupmod -o -g "$PGID" valheim; fi
if [ "$(id -u valheim)" != "$PUID" ]; then usermod -o -u "$PUID" valheim; fi

# chown only when the top-level owner is wrong (first start, or files left by an earlier root
# container); recursing over ~1 GB of game files on every start would be wasteful.
for dir in "$CONFIG_DIR" /opt/valheim "$STEAMCMD_DIR" /home/valheim; do
    if [ -d "$dir" ] && { [ "$(stat -c '%u' "$dir")" != "$PUID" ] || [ "$(stat -c '%g' "$dir")" != "$PGID" ]; }; then
        log "Fixing ownership of $dir -> $PUID:$PGID"
        chown -R "$PUID:$PGID" "$dir"
    fi
done
# The two directories the server writes to must belong to the runtime user even when the
# parent mount already had the right owner (the mkdir above may have created them as root).
chown "$PUID:$PGID" "$CONFIG_DIR" "$SERVER_DIR"

exec gosu valheim /usr/local/bin/entrypoint.sh "$@"
