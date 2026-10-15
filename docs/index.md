---
title: Home
layout: default
nav_order: 1
---

# Valheim Dedicated Server

Self-hosted Valheim dedicated server for Linux, packaged as a Docker container that installs and updates the official server through SteamCMD. Configured entirely through `.env`, with persistent worlds, healthchecks, backups and a single CLI for everything.

## What you get

- Single CLI (`./valheim`) for setup, lifecycle, status, updates, backups and restores
- The image never goes stale: SteamCMD validates and updates the game files on every container start
- Runs as an unprivileged user by default (`PUID`/`PGID`), root optional
- Graceful shutdown: the world is saved before the container stops
- Same variable names and mount paths as `lloesche/valheim-server`, so switching is a one-line change
- Healthcheck watches the server process; Watchtower pulls new images nightly
- Backup and restore scripts with retention
- Automated builds publish to GHCR, with hadolint and shellcheck on every change

## Pages

- [Installation]({{ '/installation.html' | relative_url }})
- [Configuration]({{ '/configuration.html' | relative_url }})
- [Updates]({{ '/updates.html' | relative_url }})
- [Backups]({{ '/backups.html' | relative_url }})
- [Migrating from lloesche/valheim-server]({{ '/migration.html' | relative_url }})
- [Troubleshooting]({{ '/troubleshooting.html' | relative_url }})

## Requirements

| Component      | Minimum |
| -------------- | ------- |
| OS             | Ubuntu 22.04+ or Debian 12+ |
| Docker         | 24.x or newer |
| Docker Compose | v2 (`docker compose`) |
| CPU            | 2 cores (Valheim is single-thread heavy, clock speed matters more than cores) |
| RAM            | 4 GB (8 GB recommended for 5+ players or large worlds) |
| Disk           | 6 GB free (2.2 GB game files, worlds are tens of MB) |
| Network        | UDP 2456-2457 forwarded to the host (2458 too for crossplay) |

## Source

[github.com/MrGuato/Valheim_Game_Server](https://github.com/MrGuato/Valheim_Game_Server)
