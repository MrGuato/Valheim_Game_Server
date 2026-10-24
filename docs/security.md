---
title: Security
layout: default
nav_order: 9
---

# Security

A game server is a machine on the internet that your friends connect to. Here's what this project does to keep yours safe, and what's still up to you.

## What the image does

| Area | How |
| ---- | --- |
| Least privilege | The server runs as UID/GID 1000. The container starts as root only to fix volume ownership, then drops privileges with `gosu`. `cap_add` adds only `SYS_NICE` (thread priority) |
| No inbound access from GitHub | There's no self-hosted runner, webhook or deploy key with access to your host. Your host pulls a public image, and Watchtower only acts on containers labeled for it |
| Secrets | `.env` is gitignored, and `./valheim setup` writes it with mode 600. No passwords, addresses or worlds are in the repo or the image |
| Supply chain | The image is built by GitHub Actions from this repo. The base image and actions get weekly Dependabot updates. The BepInEx pack is pinned to a version and checked against a SHA-256 hash at build time |
| Runtime downloads | Only the Valheim server itself, from Steam via SteamCMD (`app_update 896660 validate`) |
| Scanning | Every push and pull request runs hadolint (Dockerfile), shellcheck (all scripts), CodeQL (workflows), gitleaks (secrets in history) and Trivy (repo config and the built image). Results go to the repo's code scanning page |
| Logs | The json-file driver caps logs at 5 × 20 MB, so a chatty server can't fill the disk |

## What's up to you

- **A strong server password.** Valheim requires 5+ characters that don't appear in the server name. Longer is better.
- **Firewall.** Open only UDP 2456-2457 (and 2458 with crossplay). Where you can, limit the router forward to your friends' IPs. Direct connect still works, and the server just won't appear in the public list.
- **Admins.** Keep `config/adminlist.txt` short. Admins can use the server's console commands.
- **Whitelist.** For a private group, list your friends' Steam64 IDs in `config/permittedlist.txt`. Nobody else can join, even with the password.
- **Pin a release** (`IMAGE_TAG=2.1.0`) if you'd rather review updates before they run, instead of following `latest`.
- **Off-host backups.** See [Backups]({{ '/backups.html' | relative_url }}).
- **Mods.** BepInEx plugins run with the server's permissions. Install only plugins you trust, from their official pages.

## Verify what you run

{% raw %}
```bash
docker image inspect ghcr.io/mrguato/valheim-game-server:latest \
  --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}'
```
{% endraw %}

That prints the commit the image was built from. Compare it with the [commit history](https://github.com/MrGuato/valheim-game-server/commits/main) and the matching [build run](https://github.com/MrGuato/valheim-game-server/actions/workflows/build.yml).

## Reporting a vulnerability

Please use **Security → Report a vulnerability** on the [GitHub repo](https://github.com/MrGuato/valheim-game-server/security) rather than a public issue. The full policy is in [SECURITY.md](https://github.com/MrGuato/valheim-game-server/blob/main/SECURITY.md).
