# Changelog

All notable changes to this project. Releases follow [semantic versioning](https://semver.org/); image tags drop the `v` (`v2.0.0` → `2.0.0`, `2.0`).

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
- The default image is now `ghcr.io/mrguato/valheim-game-server`. The old name `ghcr.io/mrguato/valheim_game_server` is still published with the same tags, so existing installs keep updating.
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
