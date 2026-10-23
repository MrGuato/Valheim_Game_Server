---
title: Backups
layout: default
nav_order: 5
---

# Backups

Three layers, cheapest first.

## 1. Valheim's own rolling backups

The server keeps a few `WORLD_backup_auto-*` copies next to the world in `config/worlds_local/` (tune with `WORLD_BACKUPS`, `BACKUP_SHORT`, `BACKUP_LONG`). They protect against a corrupted save, not against losing the disk.

## 2. Repo backup script

```bash
./valheim backup
```

Writes `./backups/valheim-YYYY-MM-DD-HHMM.tar.gz` containing `config/worlds_local/` and the three player lists, verifies the archive, and deletes archives older than 14 days.

```bash
BACKUP_DIR=/srv/backups RETENTION_DAYS=60 ./valheim backup
```

Schedule it:

```cron
30 9 * * 0 cd /home/you/valheim-game-server && ./valheim backup >> logs/backup.log 2>&1
```

If `./config` is root-owned (you run with `PUID=0`, or the lloesche image), run it with `sudo`.

The game files in `./data` and the image are reproducible and are intentionally left out.

## 3. Off-host copies

Everything above lives on the same disk as the server. Push the tarballs somewhere else after each backup:

```bash
rsync -av --delete ./backups/ backup@nas:/srv/backups/valheim/
```

S3-compatible storage with the AWS CLI:

```bash
aws s3 sync ./backups/ s3://my-bucket/valheim/ --exclude "*" --include "valheim-*.tar.gz"
```

Restic, Borg or rclone all work the same way. Chain the command after `./valheim backup` in the cron entry.

## Restore

```bash
./valheim restore ./backups/valheim-2026-10-15-0930.tar.gz
```

The script asks for confirmation, stops the server (which saves the current world first), extracts the archive over `config/`, and starts the server. Always restore into the same project directory the backup was taken from, and take a fresh backup before restoring so the current state is not lost.

To restore a single world by hand, stop the server and copy the world folder and its `.fwl`/`.db` files (or the chunked `WORLD/` folder on newer builds) into `config/worlds_local/`, then start the server.
