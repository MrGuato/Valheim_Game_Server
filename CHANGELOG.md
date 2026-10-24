# Changelog

All notable changes to this project. Releases follow [semantic versioning](https://semver.org/); image tags drop the `v` (`v2.0.0` → `2.0.0`, `2.0`).

## [2.1.0] - 2026-10-24

The first release on Ubuntu 26.04, with one package name and a cleaner image.

### Changed
- Base image is **Ubuntu 26.04 LTS** (was 22.04). The default `ubuntu` user those images ship on UID 1000 is removed so `valheim` keeps that id. Tested against a copy of a live world before release: SteamCMD validation, world load, save on stop. Nothing changes for the host: any Linux with Docker 24+ runs it.
- The build applies Ubuntu's pending package updates, so each release carries current security fixes instead of the base image's snapshot.
- GitHub Actions bumped (checkout 7, login-action 4, metadata-action 6, build-push-action 7, setup-buildx-action 4, codeql-action 4). The README shows the container's pull count.

### Removed
- The pre-2.0 package `ghcr.io/mrguato/valheim_game_server` has been deleted. Only `ghcr.io/mrguato/valheim-game-server` exists. If your `.env` still names the old one, set `IMAGE_REPOSITORY=ghcr.io/mrguato/valheim-game-server` and run `./valheim update`.
- The unused `pebble` binary the 26.04 base image ships; Trivy flagged fourteen Go CVEs in it.

### Security
- `.trivyignore` records that starting as root is deliberate (volume ownership, then gosu to PUID/PGID), so that finding stays closed. All Trivy and CodeQL alerts on the repo are resolved.

### Upgrading from 2.0.0
Nothing to change if you follow `latest`: Watchtower or `./valheim update` picks it up and the server restarts once (it saves first). If you pin, set `IMAGE_TAG=2.1.0` and run `./valheim update`.

## [2.0.0] - 2026-10-23

A year after 1.0, the project has its own container image and is now called **valheim-game-server**.

### Added
- Own container image `ghcr.io/mrguato/valheim-game-server`: Ubuntu 22.04 + SteamCMD, game files installed and validated on every start.
- `./valheim` CLI: `setup` wizard, `start`, `stop`, `restart`, `status`, `logs`, `update`, `backup`, `restore`, `shell`, `build`. A `Makefile` wraps it.
- Runs as an unprivileged user by default (`PUID`/`PGID`, 1000), and fixes volume ownership and Valheim 1.0 world-folder permissions on start.
- Graceful shutdown that waits for the world save (`STOP_TIMEOUT`, default 120 s).
- Up-front checks for Valheim's password rules and world names.
- Game settings from `.env`: `SERVER_PRESET`, `SERVER_MODIFIERS`, `SERVER_SETKEYS`, `SAVE_INTERVAL`, Valheim's own backup settings, `SERVER_ARGS`.
- Crossplay (`CROSSPLAY=true`).
- Opt-in BepInEx (`BEPINEX=true`): the pack is pinned and checksummed in the image, and plugins go in `config/bepinex/plugins/`.
- `scripts/backup.sh` and `scripts/restore.sh`: verified tarballs with retention.
- Documentation site at <https://mrguato.github.io/valheim-game-server/>, including pages on mods, the Longhouse dashboard and security.
- Security workflow: gitleaks plus Trivy config and image scans. Added alongside hadolint, shellcheck, CodeQL and Dependabot.
- MIT license, security policy and this changelog.

### Changed
- Renamed the repository from `Valheim_Game_Server` to `valheim-game-server`. GitHub redirects the old URLs, but the docs site moved to `/valheim-game-server/`.
- The default image is now `ghcr.io/mrguato/valheim-game-server`. The old name `ghcr.io/mrguato/valheim_game_server` was still published with the same tags at the time (deleted 2026-10-24).
- Watchtower runs once a day at 05:00 (it was hourly) and only updates labeled containers.

### Removed
- The self-hosted GitHub Actions runner and its deploy workflow. Updates come from Watchtower or `git pull && ./valheim update`, so GitHub never needs access to the host.
- The old standalone `index.html` page, replaced by the docs site.

### Upgrading from 1.x
1. `./valheim backup` (or copy `config/` somewhere safe).
2. `git pull`. If your clone points at the old URL it still works; to update it, run `git remote set-url origin https://github.com/MrGuato/valheim-game-server.git`.
3. Optionally set `IMAGE_REPOSITORY=ghcr.io/mrguato/valheim-game-server` in `.env`. The old name keeps working.
4. `./valheim update`.

## [1.0] - 2025-09-03

First release: Docker Compose setup with Watchtower, deployed by a self-hosted GitHub Actions runner.

[2.0.0]: https://github.com/MrGuato/valheim-game-server/compare/v1.0...v2.0.0
[1.0]: https://github.com/MrGuato/valheim-game-server/releases/tag/v1.0
