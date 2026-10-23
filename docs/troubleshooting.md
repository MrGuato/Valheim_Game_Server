---
title: Troubleshooting
layout: default
nav_order: 10
---

# Troubleshooting

## The container exits immediately with a password error

```
[valheim] ERROR: SERVER_PASS must be at least 5 characters (Valheim rule)
[valheim] ERROR: SERVER_PASS must not appear inside SERVER_NAME (Valheim rule)
```

Those are Valheim's own rules, the server refuses to start otherwise. Fix `.env` and `./valheim update`.

## Health stays `starting` or `unhealthy`

The healthcheck has a 10-minute `start_period` to cover the first SteamCMD download. If it never turns healthy:

```bash
./valheim status
./valheim logs 200
```

Look for SteamCMD errors (network, disk full) or a Valheim crash right after `Starting:`.

## SteamCMD fails to install

Symptom: `ERROR! Failed to install app '896660'`.

- Outbound internet must work from the container: `docker run --rm curlimages/curl -sI https://steamcdn-a.akamaihd.net/`
- At least 3 GB free disk during the download
- `data/` must be writable by `PUID:PGID` (see permissions below)

`Failed to install app '896660' (Missing configuration)` on the first attempt is a SteamCMD quirk, not a real failure. The entrypoint warms SteamCMD up and retries three times; the second attempt normally succeeds. Only worry if all three fail.

Retry with `./valheim restart`; SteamCMD resumes partial downloads.

## Permission denied on worlds or game files

Symptom: `UnauthorizedAccessException` in the log, or the server creates a new empty world instead of loading yours.

The server runs as `PUID:PGID` (1000 by default). The container fixes ownership on start when it runs as root, which is the default. If you start the container with `--user` or your host blocks `chown`, do it yourself:

```bash
sudo chown -R 1000:1000 ./config ./data
./valheim restart
```

Valheim also creates world sub-folders without the execute bit on some builds; the entrypoint repairs that on every start.

## Server not visible in the community list

- `SERVER_PUBLIC=true` in `.env`
- UDP 2456 **and** 2457 forwarded to the host (2457 is the query port Steam uses to list the server)
- `sudo ufw status` shows both ports allowed
- Port forwards restricted to specific IPs hide the server from the list; use direct connect instead

Direct connect works regardless: `your.public.ip:2456`.

## Crossplay players cannot join

`CROSSPLAY=true` needs UDP 2458 as well: uncomment the port line in `docker-compose.yaml`, forward it on the router, and `./valheim update`.

## Players disconnect on world save

Large worlds pause for a moment during saves. Raise `SAVE_INTERVAL` (seconds) to save less often, and keep `./valheim backup` as your safety net.

## The world did not save on stop

`./valheim stop` sends SIGINT and waits `STOP_TIMEOUT` seconds (default 120) for Valheim to write the world; the log shows `World save (5/5) done`. If a host reboot killed the container before that, Valheim's `_backup_auto-*` copies in `config/worlds_local/` are the fallback.

## Image pull denied

Symptom: `Error response from daemon: ... denied`.

The GHCR package must be public: profile → Packages → `valheim-game-server` → Package settings → Change visibility. Or build locally:

```bash
./valheim build
IMAGE_REPOSITORY=valheim-game-server IMAGE_TAG=dev ./valheim start
```

## Watchtower keeps restarting

`client version 1.25 is too old` in `docker logs watchtower` means a Docker Engine 29+ host. The compose file pins `DOCKER_API_VERSION=1.44` on the Watchtower service to fix it; `docker compose up -d` applies it.

## Get inside the container

```bash
./valheim shell
```

Useful from inside:

```bash
pgrep -af valheim_server
ls -la /config/worlds_local
cat /opt/valheim/server/steamapps/appmanifest_896660.acf | grep buildid
```

## Reset everything

```bash
./valheim down
sudo rm -rf ./config ./data
./valheim start
```

Destructive. Take a backup first.
