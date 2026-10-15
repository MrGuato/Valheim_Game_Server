#!/usr/bin/env bash
# Runs as the valheim user (or root when PUID=0): validates settings, installs/updates the
# game through SteamCMD, starts the server and makes sure the world is saved on shutdown.
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/opt/valheim/server}"
CONFIG_DIR="${CONFIG_DIR:-/config}"
STEAMCMD_DIR="${STEAMCMD_DIR:-/opt/steamcmd}"
VALHEIM_APP_ID="${VALHEIM_APP_ID:-896660}"
UPDATE_ON_START="${UPDATE_ON_START:-true}"
STOP_TIMEOUT="${STOP_TIMEOUT:-120}"

SERVER_NAME="${SERVER_NAME:-My Valheim Server}"
WORLD_NAME="${WORLD_NAME:-Midgard}"
SERVER_PASS="${SERVER_PASS:-}"
SERVER_PUBLIC="${SERVER_PUBLIC:-true}"
SERVER_PORT="${SERVER_PORT:-2456}"
CROSSPLAY="${CROSSPLAY:-false}"
SAVE_INTERVAL="${SAVE_INTERVAL:-}"
WORLD_BACKUPS="${WORLD_BACKUPS:-}"
BACKUP_SHORT="${BACKUP_SHORT:-}"
BACKUP_LONG="${BACKUP_LONG:-}"
SERVER_PRESET="${SERVER_PRESET:-}"
SERVER_MODIFIERS="${SERVER_MODIFIERS:-}"
SERVER_SETKEYS="${SERVER_SETKEYS:-}"
SERVER_ARGS="${SERVER_ARGS:-}"

SERVER_PID=""
ARGS=()

log() { echo "[valheim] $*"; }
die() { echo "[valheim] ERROR: $*" >&2; exit 1; }
is_true() { case "${1,,}" in 1|true|yes|on) return 0 ;; *) return 1 ;; esac; }

validate() {
    if [ -z "$SERVER_PASS" ]; then
        if is_true "$SERVER_PUBLIC"; then
            die "SERVER_PASS is empty. A public server needs a password (5+ characters), or set SERVER_PUBLIC=false"
        fi
        log "WARNING: SERVER_PASS is empty, anyone who knows the address can join"
    else
        [ "${#SERVER_PASS}" -ge 5 ] || die "SERVER_PASS must be at least 5 characters (Valheim rule)"
        case "${SERVER_NAME,,}" in
            *"${SERVER_PASS,,}"*) die "SERVER_PASS must not appear inside SERVER_NAME (Valheim rule)" ;;
        esac
    fi
    [[ "$WORLD_NAME" =~ ^[A-Za-z0-9_-]+$ ]] || die "WORLD_NAME may only contain letters, digits, '-' and '_'"
    [[ "$SERVER_PORT" =~ ^[0-9]+$ ]] || die "SERVER_PORT must be a number"
}

update_server() {
    if ! is_true "$UPDATE_ON_START"; then
        log "UPDATE_ON_START=$UPDATE_ON_START, skipping SteamCMD"
        return
    fi
    [ -w "$SERVER_DIR" ] || die "$SERVER_DIR is not writable by $(id -un) (uid $(id -u)). Fix the owner of the ./data mount or set PUID/PGID to match it"

    # SteamCMD's first run self-updates and writes its config; without this warm-up the
    # very first app_update often fails with "Missing configuration".
    log "Initializing SteamCMD"
    "$STEAMCMD_DIR/steamcmd.sh" +quit >/dev/null 2>&1 || true

    local attempt rc
    for attempt in 1 2 3; do
        log "Installing / updating the Valheim dedicated server (AppID $VALHEIM_APP_ID), attempt $attempt"
        rc=0
        "$STEAMCMD_DIR/steamcmd.sh" \
            +force_install_dir "$SERVER_DIR" \
            +login anonymous \
            +app_update "$VALHEIM_APP_ID" validate \
            +quit || rc=$?
        if [ "$rc" -eq 0 ] && [ -f "$SERVER_DIR/valheim_server.x86_64" ]; then
            chmod u+x "$SERVER_DIR/valheim_server.x86_64" 2>/dev/null || true
            return
        fi
        log "WARNING: SteamCMD attempt $attempt failed (exit code $rc), retrying in 10s"
        sleep 10
    done
    log "WARNING: SteamCMD failed 3 times; trying to start with whatever is installed"
}

fix_world_dir_perms() {
    # Valheim creates world sub-folders as drw-r--r-- (no execute bit). Root does not care,
    # a regular user cannot enter them. Make every directory under the save dir traversable.
    if [ -d "$CONFIG_DIR/worlds_local" ]; then
        find "$CONFIG_DIR/worlds_local" -type d ! -perm -u+rwx -exec chmod u+rwx {} + 2>/dev/null || true
    fi
}

shutdown() {
    log "Shutdown requested, sending SIGINT so the server saves the world (waiting up to ${STOP_TIMEOUT}s)"
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill -INT "$SERVER_PID" 2>/dev/null || true
        local i
        for (( i = 0; i < STOP_TIMEOUT; i++ )); do
            kill -0 "$SERVER_PID" 2>/dev/null || break
            sleep 1
        done
        if kill -0 "$SERVER_PID" 2>/dev/null; then
            log "Server did not exit within ${STOP_TIMEOUT}s, killing it"
            kill -KILL "$SERVER_PID" 2>/dev/null || true
        fi
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    log "Server stopped"
    exit 0
}

build_args() {
    ARGS=( -nographics -batchmode -name "$SERVER_NAME" -port "$SERVER_PORT" -world "$WORLD_NAME" -savedir "$CONFIG_DIR" )
    if is_true "$SERVER_PUBLIC"; then ARGS+=( -public 1 ); else ARGS+=( -public 0 ); fi
    if [ -n "$SERVER_PASS" ];   then ARGS+=( -password "$SERVER_PASS" ); fi
    if is_true "$CROSSPLAY";    then ARGS+=( -crossplay ); fi
    if [ -n "$SAVE_INTERVAL" ]; then ARGS+=( -saveinterval "$SAVE_INTERVAL" ); fi
    if [ -n "$WORLD_BACKUPS" ]; then ARGS+=( -backups "$WORLD_BACKUPS" ); fi
    if [ -n "$BACKUP_SHORT" ];  then ARGS+=( -backupshort "$BACKUP_SHORT" ); fi
    if [ -n "$BACKUP_LONG" ];   then ARGS+=( -backuplong "$BACKUP_LONG" ); fi
    if [ -n "$SERVER_PRESET" ]; then ARGS+=( -preset "$SERVER_PRESET" ); fi
    local m k
    for m in $SERVER_MODIFIERS; do ARGS+=( -modifier "${m%%:*}" "${m#*:}" ); done
    for k in $SERVER_SETKEYS;   do ARGS+=( -setkey "$k" ); done
    if [ -n "$SERVER_ARGS" ]; then
        # shellcheck disable=SC2206
        ARGS+=( $SERVER_ARGS )
    fi
}

main() {
    log "Valheim Dedicated Server container by MrGuato, running as $(id -un) (uid $(id -u))"
    validate
    mkdir -p "$CONFIG_DIR" "$SERVER_DIR"
    [ -w "$CONFIG_DIR" ] || die "$CONFIG_DIR is not writable by $(id -un) (uid $(id -u)). Fix the owner of the ./config mount or set PUID/PGID to match it"
    update_server
    [ -x "$SERVER_DIR/valheim_server.x86_64" ] || die "valheim_server.x86_64 not found in $SERVER_DIR (SteamCMD download failed?)"
    fix_world_dir_perms
    build_args

    export SteamAppId=892970
    export LD_LIBRARY_PATH="$SERVER_DIR/linux64:${LD_LIBRARY_PATH:-}"
    export templdpath="$LD_LIBRARY_PATH"

    local visibility=private
    if is_true "$SERVER_PUBLIC"; then visibility=public; fi
    log "Starting: name='$SERVER_NAME' world='$WORLD_NAME' port=$SERVER_PORT ($visibility, crossplay=$CROSSPLAY)"
    log "Saves: $CONFIG_DIR   Game files: $SERVER_DIR"

    trap shutdown TERM INT
    cd "$SERVER_DIR"
    "$SERVER_DIR/valheim_server.x86_64" "${ARGS[@]}" &
    SERVER_PID=$!
    local rc=0
    wait "$SERVER_PID" || rc=$?
    log "Server exited with code $rc"
    exit "$rc"
}

main "$@"
