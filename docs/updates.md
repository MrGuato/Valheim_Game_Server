---
title: Updates
layout: default
nav_order: 4
---

# Updates

Two things update independently: the container image (Docker) and the game files (SteamCMD).

## Game updates (the frequent one)

Valheim patches land on Steam. Because `UPDATE_ON_START=true`, every container start runs `app_update 896660 validate` and pulls the new build. So after a patch:

```bash
./valheim restart
```

Players need the matching client version, so coordinate the restart with them. The world is saved before the restart.

## Image updates

```bash
./valheim update
```

That pulls the latest image from GHCR, recreates the container and lets SteamCMD validate the game files on start. Worlds and config persist because they live in `./config`.

## Automatic image updates

`docker-compose.yaml` includes Watchtower, which checks GHCR every day at 05:00 (in the `TZ` from `.env`, UTC if unset) and recreates the Valheim container when a new image for your tag exists. It only touches containers with the `com.centurylinklabs.watchtower.enable=true` label, which the Valheim service carries.

Watchtower's `--schedule` takes six cron fields with seconds first, so the compose file uses `0 0 5 * * *`. The usual five-field `0 5 * * *` would run every hour at minute 5.

Remove the `watchtower` service from the compose file if you prefer manual updates.

## Pin to a specific image tag

```ini
IMAGE_TAG=v1.0.0
```

```bash
./valheim update
```

## Skip SteamCMD on start

For hosts with restricted internet:

```ini
UPDATE_ON_START=false
```

The container starts the existing game files without contacting Steam. To update later, flip it back and `./valheim update`, or run a one-shot update inside the container:

```bash
./valheim shell
/opt/steamcmd/steamcmd.sh +force_install_dir /opt/valheim/server +login anonymous +app_update 896660 validate +quit
exit
./valheim restart
```

## Scheduled restarts

A nightly restart picks up game patches and clears memory:

```cron
10 5 * * * cd /home/game_server/Valheim_Game_Server && ./valheim restart >> logs/restart.log 2>&1
```
