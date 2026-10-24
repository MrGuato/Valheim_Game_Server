---
title: Home
layout: default
nav_order: 1
---

<p align="center"><img src="{{ '/assets/logo.svg' | relative_url }}" width="120" alt="Valheim Game Server logo"></p>

# Valheim Game Server
{: .text-center }

A self-hosted Valheim dedicated server you can set up in five minutes and trust with your world.
{: .fs-6 .fw-300 .text-center }

[Get started]({{ '/installation.html' | relative_url }}){: .btn .btn-primary .mr-2 }
[View on GitHub](https://github.com/MrGuato/valheim-game-server){: .btn .mr-2 }
[Releases](https://github.com/MrGuato/valheim-game-server/releases){: .btn }
{: .text-center }

---

```bash
git clone https://github.com/MrGuato/valheim-game-server.git
cd valheim-game-server
./valheim setup
./valheim start
```

When the log says `Game server connected`, players join with `your.public.ip:2456`.

## Why this one

I host a Valheim world for my family and friends. This is the setup it runs on, built so I could stop worrying about it.

**Your world comes first.** Shutdowns wait for Valheim's world save before the process is killed. `./valheim backup` writes verified tarballs with retention, and `./valheim restore` puts one back. Valheim 1.0 world folders with broken permissions are repaired on every start, so the server doesn't quietly create an empty new world.

**Set it up once.** One CLI covers setup, status, logs, updates, backups and restores. The image ships only SteamCMD and patches the game on every start, so a restart is a game update. Watchtower pulls new images once a night.

**Safe by default.** The server runs as an unprivileged user. GitHub has no way into your host. The image is built in public and scanned on every change (hadolint, shellcheck, CodeQL, gitleaks, Trivy). The optional BepInEx pack is pinned and checksummed. See [Security]({{ '/security.html' | relative_url }}).

**Pairs with a dashboard.** [Longhouse]({{ '/dashboard.html' | relative_url }}), a separate project, adds a live web page with who's online, boss progress, leaderboards and player profiles.

## What you get

- `./valheim` CLI for setup, lifecycle, status, updates, backups and restores (`make` works too)
- SteamCMD validates and updates the game files on every container start
- Runs as `PUID`/`PGID` 1000 by default. Root is optional
- The world is saved before the container stops (`STOP_TIMEOUT`)
- Valheim's password and world-name rules are checked before the server starts
- Presets, modifiers and world keys from `.env`
- Crossplay for Xbox and Microsoft Store players
- Opt-in BepInEx for server-side plugins
- Healthcheck, log rotation and nightly Watchtower updates
- Versioned releases you can pin (`IMAGE_TAG=2.1.0`)

## Pages

| Page | What's in it |
| ---- | ------------ |
| [Installation]({{ '/installation.html' | relative_url }}) | From a fresh Ubuntu host to your first login |
| [Configuration]({{ '/configuration.html' | relative_url }}) | Every variable, presets, modifiers, player lists, volumes |
| [Updates]({{ '/updates.html' | relative_url }}) | Game patches, image updates, pinning a release |
| [Backups]({{ '/backups.html' | relative_url }}) | Local, scheduled and off-host backups, restoring |
| [Mods (BepInEx)]({{ '/mods.html' | relative_url }}) | Server-side plugins, and keeping players' achievements |
| [Dashboard (Longhouse)]({{ '/dashboard.html' | relative_url }}) | The companion web dashboard |
| [Security]({{ '/security.html' | relative_url }}) | What the image does to protect you, and how to report a problem |
| [Troubleshooting]({{ '/troubleshooting.html' | relative_url }}) | Common errors and fixes |

## Requirements

| Component      | Minimum |
| -------------- | ------- |
| OS             | Ubuntu 22.04+ or Debian 12+ |
| Docker         | 24.x or newer |
| Docker Compose | v2 (`docker compose`) |
| CPU            | 2 cores (Valheim leans on one thread, so clock speed matters more than cores) |
| RAM            | 4 GB (8 GB recommended for 5+ players or large worlds) |
| Disk           | 6 GB free (2.2 GB of game files; worlds are tens of MB) |
| Network        | UDP 2456-2457 forwarded to the host (2458 too for crossplay) |

## Source

[github.com/MrGuato/valheim-game-server](https://github.com/MrGuato/valheim-game-server), MIT licensed. Valheim is a trademark of Iron Gate AB. This project isn't affiliated with Iron Gate or Coffee Stain and doesn't redistribute game files.
