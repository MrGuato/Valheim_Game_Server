# Valheim Dedicated Server (native Linux build) by MrGuato
# The image is immutable: it ships SteamCMD only. The game files are downloaded and
# validated on every container start (UPDATE_ON_START=true), so the image never goes
# stale between Valheim patches. Saves live in /config, game files in /opt/valheim.
FROM ubuntu:26.04

LABEL org.opencontainers.image.source="https://github.com/MrGuato/Valheim_Game_Server" \
      org.opencontainers.image.description="Valheim Dedicated Server (SteamCMD, native Linux build) by MrGuato" \
      org.opencontainers.image.authors="MrGuato"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    STEAMCMD_DIR=/opt/steamcmd \
    SERVER_DIR=/opt/valheim/server \
    CONFIG_DIR=/config \
    VALHEIM_APP_ID=896660

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl locales tzdata procps gosu \
      lib32gcc-s1 lib32stdc++6 libc6:i386 \
      libsdl2-2.0-0 libpulse0 libpulse-mainloop-glib0 libatomic1 \
 && sed -i 's/^# \(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 valheim \
 && useradd -u 1000 -g 1000 -m -s /bin/bash valheim \
 && mkdir -p "$STEAMCMD_DIR" "$SERVER_DIR" "$CONFIG_DIR" \
 && curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
      | tar -xz -C "$STEAMCMD_DIR" \
 && chown -R valheim:valheim "$STEAMCMD_DIR" /opt/valheim "$CONFIG_DIR" /home/valheim

COPY docker-entrypoint.sh entrypoint.sh healthcheck.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

# 2456 game, 2457 query, 2458 crossplay (PlayFab)
EXPOSE 2456/udp 2457/udp 2458/udp

WORKDIR /opt/valheim/server

HEALTHCHECK --interval=30s --timeout=10s --start-period=10m --retries=5 \
  CMD ["/usr/local/bin/healthcheck.sh"]

# Starts as root to fix volume ownership, then drops to the valheim user (see docker-entrypoint.sh)
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
