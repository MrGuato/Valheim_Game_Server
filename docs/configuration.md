---
title: Configuration
layout: default
nav_order: 3
---

# Configuration

All server settings are environment variables in `.env`. The entrypoint turns them into Valheim command line flags on every container start.

## Apply changes

```bash
nano .env
./valheim update
```

`update` recreates the container, which re-reads `.env`.

## Variable reference

### Server identity

| Variable        | Default              | Description |
| --------------- | -------------------- | ----------- |
| `SERVER_NAME`   | `Saberguard Valheim` | Name shown in the server browser |
| `WORLD_NAME`    | `Midgard`            | World to load or create under `config/worlds_local/`. Letters, digits, `-` and `_` only |
| `SERVER_PASS`   | _required_           | Join password. 5+ characters and it must not appear inside `SERVER_NAME`. Empty is allowed only with `SERVER_PUBLIC=false` |
| `SERVER_PUBLIC` | `true`               | `true` lists the server in the community browser, `false` is direct-connect only |
| `CROSSPLAY`     | `false`              | `true` enables PlayFab crossplay for Xbox and Microsoft Store players. Also open `2458/udp` in `docker-compose.yaml` |
| `TZ`            | `America/New_York`   | Time zone for log timestamps |

### Network

| Variable      | Default | Description |
| ------------- | ------- | ----------- |
| `SERVER_PORT` | `2456`  | Game port (UDP) |
| `QUERY_PORT`  | `2457`  | Steam query port (UDP). Valheim always uses game port + 1, keep them in sync |

### Image and runtime

| Variable           | Default                                   | Description |
| ------------------ | ----------------------------------------- | ----------- |
| `IMAGE_REPOSITORY` | `ghcr.io/mrguato/valheim-game-server`     | Image source. Change it to run a fork or a locally built image |
| `IMAGE_TAG`        | `latest`                                  | Image tag. Pin a release such as `2.0.0` for production |
| `CONTAINER_NAME`   | `valheim`                                 | Docker container name |
| `PUID`             | `1000`                                    | UID the server runs as. Match the owner of `./config` and `./data`. `0` runs as root |
| `PGID`             | `1000`                                    | GID the server runs as |
| `UPDATE_ON_START`  | `true`                                    | Run SteamCMD `app_update validate` on every container start |
| `STOP_TIMEOUT`     | `120`                                     | Seconds to wait for the world save on shutdown before the process is killed |
| `BEPINEX`          | `false`                                   | Load the BepInEx mod loader (BepInExPack_Valheim, baked into the image). Put plugin DLLs in `config/bepinex/plugins/`; their configs land in `config/bepinex/config/` |

### Game settings

All optional. Empty means Valheim's own default.

| Variable           | Valheim flag    | Description |
| ------------------ | --------------- | ----------- |
| `SAVE_INTERVAL`    | `-saveinterval` | Seconds between world saves (default 1800) |
| `WORLD_BACKUPS`    | `-backups`      | Number of automatic world backups Valheim keeps next to the world (default 4) |
| `BACKUP_SHORT`     | `-backupshort`  | Seconds between the first automatic backups (default 7200) |
| `BACKUP_LONG`      | `-backuplong`   | Seconds between later automatic backups (default 43200) |
| `SERVER_PRESET`    | `-preset`       | `normal`, `casual`, `easy`, `hard`, `hardcore`, `immersive` or `hammer` |
| `SERVER_MODIFIERS` | `-modifier`     | Space separated `key:value` pairs, see below |
| `SERVER_SETKEYS`   | `-setkey`       | Space separated keys, see below |
| `SERVER_ARGS`      | _verbatim_      | Anything else appended to the command line |

Modifier keys and values:

| Key            | Values |
| -------------- | ------ |
| `combat`       | `veryeasy`, `easy`, `hard`, `veryhard` |
| `deathpenalty` | `casual`, `veryeasy`, `easy`, `hard`, `hardcore` |
| `resources`    | `muchless`, `less`, `more`, `muchmore`, `most` |
| `raids`        | `none`, `muchless`, `less`, `more`, `muchmore` |
| `portals`      | `casual`, `hard`, `veryhard` |

Set keys: `nobuildcost`, `playerevents`, `passivemobs`, `nomap`.

Example for a relaxed server:

```ini
SERVER_MODIFIERS=deathpenalty:casual raids:less
SERVER_SETKEYS=passivemobs
```

Presets and modifiers are applied when the world is created and whenever the server starts, the same way the in-game world modifier menu works.

## Player lists

Valheim reads three files from `config/`, one ID per line (Steam64 IDs, or platform IDs for crossplay players):

| File                 | Purpose |
| -------------------- | ------- |
| `adminlist.txt`      | Players who can use admin console commands |
| `bannedlist.txt`     | Banned players |
| `permittedlist.txt`  | Whitelist. If non-empty, only these players can join |

Edit them while the server runs; Valheim reloads them, but a restart is the safe way to be sure.

## Volumes

| Host path    | Container path    | Contents |
| ------------ | ----------------- | -------- |
| `./config`   | `/config`         | `worlds_local/` (worlds), player lists, `prefs` |
| `./data`     | `/opt/valheim`    | Game files from SteamCMD, reproducible |
| `./backups`  | `/config/backups` | Backup tarballs from `./valheim backup` |

`./config` and `./data` must be owned by `PUID:PGID`. The container fixes that on its first start when it runs as root (the default), so you normally never touch it.

## Pinning an image version

```ini
IMAGE_TAG=2.0.0
```

Then `./valheim update` only pulls that version. Tags are listed on the [container image page](https://github.com/MrGuato/valheim-game-server/pkgs/container/valheim-game-server). Watchtower only follows the tag you pinned.
