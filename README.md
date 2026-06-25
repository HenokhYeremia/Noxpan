![Noxpan v3.0 Banner](https://cdn.jsdelivr.net/gh/HenokhYeremia/Noxpan@main/assets/noxpan_banner.svg)

# NOXPAN v3.0
### Multi-Game Roblox Script Hub

[![Version](https://img.shields.io/badge/version-3.0-ff0066?style=for-the-badge&logo=lua&logoColor=white&labelColor=1a1a2e)](https://github.com/HenokhYeremia/Noxpan)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-00ff88?style=for-the-badge&logo=windows&logoColor=white&labelColor=1a1a2e)]()
[![Executors](https://img.shields.io/badge/executors-Delta%20%7C%20Xeno%20%7C%20Solara%20%7C%20Velocity-0088ff?style=for-the-badge&logo=roblox&logoColor=white&labelColor=1a1a2e)]()
[![License](https://img.shields.io/badge/license-MIT-8800ff?style=for-the-badge&logo=github&logoColor=white&labelColor=1a1a2e)]()

```
loadstring(game:HttpGet("https://raw.githubusercontent.com/HenokhYeremia/Noxpan/main/loader.lua"))()
```

| 4 Games | 12 Modules | 20+ Features | Free / Premium |
|---------|-----------|-------------|----------------|
| Supported | Loaded | Available | Tier System |

---

## Features

### Fishing Engine
- Auto-cast & equip rod
- 3 bite detection modes: **Smart**, **Normal**, **Aggressive**
- Auto-reel on bite
- Fish counter + earnings tracker
- Cast / reel / max-wait sliders
- Auto-sell every 5 fish
- Auto-bait detection

### Player Boosts
- **WalkSpeed** slider (16–250)
- **Jump Power** slider (50–250)
- Anti-Drown
- NoClip (phase through walls)
- Infinite Jump
- Fly mode (WASD + Space + Shift)
- Auto-reapply on respawn

### ESP System
- Fish ESP (green highlight)
- Player ESP (red highlight)
- Chest / Loot ESP (gold highlight)
- Billboard name + distance display
- Per-type color coding
- Adjustable scan radius

### Utilities
- Auto-clicker (0.01s–1s interval)
- Auto-collect dropped items
- Anti-ban protection
- Persistent settings (save/load)
- Notification system
- Error-safe (all pcall wrapped)

---

## Supported Games

| Game | Game ID | Status |
|------|---------|--------|
| **Pemancing FishIt** | `6701277882` | Optimized |
| **Sawah Indo** | `9691752199` | Generic |
| **FishZar** | `9721900284` | Generic |
| **Sailor** | `9186719164` | Generic |

> Unknown games fall back to generic fishing detection. Add new Game IDs to `GAMES` table in `loader.lua` to enable auto-detection.

---

## User Tiers

| Tier | Access | Features |
|------|--------|----------|
| **PREMIUM** | All features | Fishing engine, ESP, Fly, NoClip, Auto-clicker, Auto-farm, Anti-ban, Player boosts |
| **FREE** | Basic only | Speed boost, Jump boost, Anti-drown, Basic hub, WalkSpeed slider |
| **BANNED** | No access | Blocked from loading |

Edit `users.txt` to set user tiers: `Username:premium`, `Username:free`, `Username:ban`

---

## Project Structure

```
Noxpan/
  loader.lua              Entry point — multi-game hub
  main_free.lua           Legacy free loader
  main_premium.lua        Legacy premium loader
  users.txt               User tier database
  modules/
    hub.lua               GUI (4 tabs, draggable, minimize)
    fishing.lua           Auto-fishing engine
    player.lua            Player boosts
    esp.lua               ESP system
    autoclick.lua         Auto-clicker
    autofarm.lua          Auto-farm utilities
    antiban.lua           Anti-detection
    settings.lua          Persistent settings
    game_fishit.lua       FishIt-specific module
    game_fishing.lua      Generic fallback module
    ui.lua                Notification system
    utils.lua             Shared utilities
  assets/
    noxpan_banner.svg     Animated banner (via jsDelivr CDN)
  json/
    config.json           Hub metadata
```

---

## Loader Flow

```
User runs loader.lua
  ├── Polyfill executor APIs (mouse1click, fireproximityprompt)
  ├── Fetch config.json + users.txt from GitHub
  ├── Check user status (premium / free / ban)
  ├── Detect game by GameId
  │     ├── Known game → load game-specific module
  │     └── Unknown  → use generic fallback
  ├── Load modules (utils, ui, player, settings...)
  │     └── Premium tier also loads: fishing, esp, autoclick, etc.
  └── Init hub GUI → ready to use
```

---

## Compatible Executors

| Executor | Platform | Support |
|----------|----------|---------|
| **Delta** | Android | Full |
| **Xeno** | Windows | Full |
| **Solara** | Windows | Full |
| **Velocity** | Windows | Full |
| Synapse Z / Script-Ware | Windows | Native |

---

## Notes

- Script loads from **GitHub raw** — internet connection required
- Executor must support `loadstring` and `HttpGet`
- `users.txt` is **public** — do not store sensitive credentials here
- For production auth, replace with a backend API

---

*Noxpan v3.0 — Developed by [HenokhYeremia](https://github.com/HenokhYeremia)*

[![Last Commit](https://img.shields.io/github/last-commit/HenokhYeremia/Noxpan?style=flat-square&color=8800ff)](https://github.com/HenokhYeremia/Noxpan/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/HenokhYeremia/Noxpan?style=flat-square&color=ff0066)](https://github.com/HenokhYeremia/Noxpan)
