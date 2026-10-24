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

## Pin a release

`latest` follows `main`. To update only when you choose, pin a release:

```ini
IMAGE_TAG=2.1.0
```

```bash
./valheim update
```

Image tags drop the `v` from the git tag: release `v2.0.0` publishes `2.0.0` and `2.0`. Pinning `2.0` picks up patch releases (2.0.1, 2.0.2) but never 2.1. Watchtower follows whatever tag you pin. Release notes are on the [releases page](https://github.com/MrGuato/valheim-game-server/releases) and in the [changelog](https://github.com/MrGuato/valheim-game-server/blob/main/CHANGELOG.md).

## Image name

The image is `ghcr.io/mrguato/valheim-game-server`. Before 2.0.0 it was `ghcr.io/mrguato/valheim_game_server`; that package was deleted on 2026-10-24, so an `.env` that still points at it can no longer pull. To move to the new name:

```ini
IMAGE_REPOSITORY=ghcr.io/mrguato/valheim-game-server
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

A nightly restart picks up game patches and clears memory. It disconnects anyone still playing, so pick an hour when your group is asleep:

```cron
10 5 * * * cd /home/you/valheim-game-server && ./valheim restart >> logs/restart.log 2>&1
```
