# Security policy

## Reporting a problem

Please don't open a public issue for a security problem. Use GitHub's private reporting instead: **Security → Report a vulnerability** on this repo. I'll reply within a week and credit you in the release notes if you'd like.

Useful things to include: what you found, how to reproduce it, and which image tag or commit you tested.

## What's covered

- The container image `ghcr.io/mrguato/valheim-game-server` (and the old name `ghcr.io/mrguato/valheim_game_server`)
- The scripts in this repo: `valheim`, the entrypoints, `scripts/`
- The GitHub Actions workflows

The Valheim server itself is Iron Gate's software, downloaded from Steam at runtime. Problems in the game go to [Iron Gate](https://valheim.com/support/). Problems in BepInEx or a plugin go to that project.

## Supported versions

| Version  | Supported |
| -------- | --------- |
| 2.x      | ✅ |
| 1.x      | ❌ (the 2025 compose setup, superseded by the image) |

## How the project keeps itself safe

- The server runs as an unprivileged user (UID 1000) inside the container. Root is only used at start to fix volume ownership, then dropped with `gosu`.
- No secrets live in the repo. `.env` is gitignored, and `./valheim setup` writes it with mode 600.
- Nothing on GitHub can reach your host. There's no self-hosted runner or deploy hook; the host pulls a public image.
- The BepInEx pack is pinned to a version and checked against a SHA-256 hash at build time. Nothing is downloaded at server start except the game itself, from Steam.
- Every push and pull request runs hadolint, shellcheck, CodeQL, gitleaks (secret scanning) and Trivy (repo config and the built image). Findings go to the repo's code scanning page.
- Dependabot opens weekly updates for the base image and GitHub Actions.
