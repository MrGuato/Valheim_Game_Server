---
title: Mods (BepInEx)
layout: default
nav_order: 6
---

# Mods (BepInEx)

The image can load [BepInEx](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/), the mod loader most Valheim mods use. It's off by default.

## Turn it on

```ini
BEPINEX=true
```

```bash
./valheim update
```

On the next start the log shows:

```
[valheim] BepInEx 5.4.2351 enabled, plugins in /config/bepinex/plugins
```

The BepInExPack is baked into the image at a pinned version, and the build checks it against a SHA-256 hash. A server start never downloads mod-loader code.

## Where things go

| Host path                    | What goes there |
| ---------------------------- | --------------- |
| `config/bepinex/plugins/`    | Plugin `.dll` files (or one folder per plugin) |
| `config/bepinex/config/`     | Plugin settings (`.cfg`), created on first start. `BepInEx.cfg` lives here too |
| `config/bepinex/patchers/`   | Preloader patchers, rarely needed |

They sit in the same place `lloesche/valheim-server` uses, so an existing plugin folder works as is. They live under `config/`, so `./valheim backup` includes them and game updates don't wipe them.

## Add or update a plugin

**Stop the server before you swap a DLL.**

```bash
./valheim stop
cp SomePlugin.dll config/bepinex/plugins/
./valheim start
```

Valheim keeps reading a plugin's file after it loads it. If you replace the file while the server runs, the game reads the new file the first time it reaches code it hasn't run yet. That can be hours later, for example the first time someone sleeps. Mono then crashes (`Assertion at metadata.c ... heap_blob.size`, exit code 134) and the world rolls back to the last save. Stopping first also saves the world, so nothing is lost.

## Server-only vs. client mods

Mods come in two kinds:

- **Server-only** plugins run on the server and need nothing on players' PCs, for example the [Longhouse plugin]({{ '/dashboard.html' | relative_url }}), logging and admin tools. Players join with a vanilla game.
- **Client + server** mods change gameplay, items or UI, and every player needs the same mod and version. Check each mod's page.

### Achievements

Valheim decides Steam achievements on each player's own PC. Installing BepInEx **on a player's PC** marks that player's game as modded, and a modded game doesn't earn achievements. Running BepInEx **on the server** marks only the server, and the server never sends that to players.

So server-only plugins are safe for your players' achievements. Client mods aren't, for anyone who installs them.

## Turn it off

```ini
BEPINEX=false
```

```bash
./valheim update
```

The loader files stay on disk but never load, and your plugins and their configs remain in `config/bepinex/`.
