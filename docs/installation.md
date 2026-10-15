---
title: Installation
layout: default
nav_order: 2
---

# Installation

Step-by-step setup on a fresh Ubuntu 22.04 or 24.04 host.

## 1. Install Docker

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker "$USER"
newgrp docker
docker run --rm hello-world
```

## 2. Clone the repo

```bash
git clone https://github.com/MrGuato/Valheim_Game_Server.git
cd Valheim_Game_Server
chmod +x valheim
```

## 3. Run setup

```bash
./valheim setup
```

The wizard asks for the server name, world name, password, public listing, crossplay and time zone. It writes `.env` (mode 600) and creates `config/`, `data/`, `backups/` and `logs/` owned by UID 1000.

Valheim enforces two password rules: at least 5 characters, and the password must not appear inside the server name. The wizard checks both.

To skip the wizard:

```bash
cp .env.example .env
nano .env
mkdir -p config data backups logs
sudo chown -R 1000:1000 config data
```

## 4. Open the firewall

On the host:

```bash
sudo ufw allow 2456:2457/udp
sudo ufw allow 2458/udp    # only if CROSSPLAY=true
```

On your router, forward UDP 2456-2457 (and 2458 for crossplay) to the host. Restrict the forward to your friends' IPs if you do not need to appear in the public server list.

## 5. Start the server

```bash
./valheim start
```

That pulls the image from GHCR, starts the container and tails the logs. The first start downloads about 2.2 GB of game files through SteamCMD. When you see this, the world is loaded:

```
[valheim] Starting: name='...' world='...' port=2456 (public, crossplay=false)
...
Game server connected
```

## 6. Connect

Direct connect from the Valheim main menu with `your.public.ip:2456`, or find the server in the community list when `SERVER_PUBLIC=true`.

Note: if you forwarded the ports for specific IPs only, the server will not show up in the public list even with `SERVER_PUBLIC=true`. Use direct connect.

## Optional: build the image locally

```bash
./valheim build
IMAGE_REPOSITORY=valheim_game_server IMAGE_TAG=dev ./valheim start
```

## Optional: scheduled backups

```bash
crontab -e
```

```cron
30 9 * * 0 cd /home/game_server/Valheim_Game_Server && ./valheim backup >> logs/backup.log 2>&1
```

See [Backups]({{ '/backups.html' | relative_url }}).

## Optional: deploy from GitHub Actions

The repo ships `.github/workflows/deploy.yml`, which runs on a self-hosted runner on the game host and executes a deploy script on every push to `main` (documentation-only pushes are ignored). The script resets the checkout to `origin/main`, pulls images and runs `docker compose up -d`. To use it, register a self-hosted runner on the host and keep your `.env` outside git (it already is). Anything not committed is wiped by the reset.
