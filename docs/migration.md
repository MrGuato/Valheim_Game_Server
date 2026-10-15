---
title: Migrating from lloesche
layout: default
nav_order: 6
---

# Migrating from lloesche/valheim-server

This image was designed as a drop-in replacement for `ghcr.io/lloesche/valheim-server`:

- same variable names for the things that matter (`SERVER_NAME`, `WORLD_NAME`, `SERVER_PASS`, `SERVER_PUBLIC`, `CROSSPLAY`, `TZ`)
- same mount paths inside the container (`/config` for worlds and lists, `/opt/valheim` for game files)

So an existing `./config` and `./data` keep working, and you can switch back by changing one variable.

## What is different

| lloesche feature | Here |
| ---------------- | ---- |
| `BACKUPS=true`, `BACKUPS_CRON`, `BACKUPS_MAX_AGE` (cron inside the container) | Not implemented. Use `./valheim backup` from the host cron, see [Backups]({{ '/backups.html' | relative_url }}) |
| `UPDATE_CRON`, `UPDATE_IF_IDLE` | Game updates happen on every start (`UPDATE_ON_START`). Schedule `./valheim restart` from cron |
| `RESTART_CRON`, `RESTART_IF_IDLE` | Schedule `./valheim restart` from cron |
| Runs as root by default | Runs as `PUID`/`PGID` (1000) by default. Set `PUID=0` to keep root |
| BepInEx / ValheimPlus mod loaders, status HTTP endpoint, Discord hooks | Not included |

## Steps

1. Take a backup while the old image is still running:
   ```bash
   sudo ./valheim backup
   ```
2. In `.env`, point at this image (or delete the two lines to use the compose default):
   ```ini
   IMAGE_REPOSITORY=ghcr.io/mrguato/valheim_game_server
   IMAGE_TAG=latest
   ```
   Decide who the server runs as. `PUID=1000` (default) makes the container chown `./config` and `./data` to 1000 on its first start and fixes world folders that lloesche created without the execute bit. `PUID=0` keeps everything root-owned, exactly as before.
3. Recreate the container:
   ```bash
   ./valheim update
   ```
4. Watch the first start:
   ```bash
   ./valheim logs
   ```
   You should see SteamCMD validate the existing game files (fast, nothing to download), then `Starting: name=... world=...` with your world name, then Valheim's own `Load world: <name>` and `Game server connected`. A world that shows up as brand new means the server could not read your world folder: check ownership (see Troubleshooting).
5. Confirm the world loaded by joining, then check that `config/worlds_local/` keeps receiving `World save ... done` lines in the log.

## Rolling back

```ini
IMAGE_REPOSITORY=ghcr.io/lloesche/valheim-server
IMAGE_TAG=latest
```

```bash
./valheim update
```

The lloesche image runs as root and does not care about file ownership, so a rollback needs no cleanup.
