#!/usr/bin/env bash
# Healthy as soon as the Valheim server process is running. The compose start_period
# covers the SteamCMD download that happens before it starts.
set -euo pipefail

if pgrep -f 'valheim_server\.x86_64' >/dev/null 2>&1; then
    exit 0
fi
exit 1
