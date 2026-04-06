# Project: Fort-Defense Godot 4 Prototype

## Overview
Top-down fort-defense game. Enemies spawn from the top, drift down, attack the bottom fort zone. Archers auto-fire. Player clicks to attack. Dead enemies drop coins (money) and crystals (XP).

**Window size:** 1280x720. All files in project root.

---

## Entrypoint Scene

### `Main.tscn` — sole scene
Root type: `Node2D` (script: `main.gd`)

```
MainNode2D (Node2D, root)
├── BackgroundControl (Control)
│   ├── BattlefieldRect (ColorRect, y=0→580, dark battlefield)
│   └── FortRect        (ColorRect, y=580→720, cyan = fort zone)
├── WorldNode2D (Node2D)
│   ├── Enemies         (Node2D)   — enemy container
│   ├── Projectiles     (Node2D)   — arrow container
│   ├── Pickups         (Node2D)   — coin/crystal container
│   ├── EnemySpawner    (Node)     — spawns enemies + pickups on death
│   │   └── Timer (autostart)
│   ├── CursorAttack    (Node)     — player click damage
│   ├── FortUnits       (Node2D)   — dynamically spawned archers
│   ├── ArcherFormationAnchor (Marker2D, pos=640,650) — formation reference point
│   ├── ArcherManager   (Node)     — manages archer spawning + formation
│   └── FortZone        (Node)     — fort HP, destroyed signal
└── HUD (CanvasLayer)
    ├── Label            (Label, unused placeholder)
    ├── FortHealthLabel  (Label, right-aligned)
    ├── PlayerLevelLabel (Label)
    ├── PlayerXPLabel    (Label, blue text)
    ├── MoneyLabel       (Label)
    ├── BuyArcherButton  (Button)
    └── LevelUpOverlay   (ColorRect, semi-transparent dimmer)  — from LevelUpOverlay.tscn
         └── CenterContainer
              └── VBoxContainer
                   ├── TitleLabel
                   └── ChoicesContainer
```

---

## Scripts — by system

### Game Coordinator
- **`main.gd`** — root script. Coordinates everything.
  - State: `money`, `player_level`, `current_xp`, `xp_to_next_level`, `pending_level_ups`, `archer_damage_bonus`
  - XP/level-up flow (calls `UpgradePool`, opens `LevelUpOverlay`)
  - Buy archer logic (`ARCHER_COST = 10`)
  - HUD label updates
  - Pickups → spawns `pickups_container`
  - Level-up overlay → `LevelUpOverlay`, pause/resume
  - Node paths: `$WorldNode2D/EnemySpawner`, `$WorldNode2D/ArcherManager`, `$WorldNode2D/CursorAttack`, `$WorldNode2D/FortZone`, `$HUD/*`

### Enemy System
- **`enemy.gd`** — enemy behavior
  - Moves downward toward `wall_y` (580). On contact, enters "attacking" state and damages fort.
  - HP, `attack_damage`, `attack_interval` are exported.
  - Adds self to `"enemies"` group.
  - Emits `died(drop_position)` on death.
- **`enemy_spawner.gd`** — spawns enemies + pickups
  - Timer-driven spawning. Picks random X at top (`spawn_y = -40`).
  - On enemy death: spawns 1 coin (value=1) and 1 crystal (value=2) at death position.
  - Forwards `pickup_collected` signal to `main.gd`.
  - `pickup_target_position = Vector2(640, 650)` — where pickups drift toward.

### Archer System
- **`archer.gd`** — individual archer unit
  - Fires arrows toward closest enemy within `range` (500).
  - `base_damage` (default 1) — set by `ArcherManager` on spawn, modifiable by level-up upgrade via `set_base_damage()`.
  - `FireTimer` (0.75s autostart) controls fire rate.
- **`archer_manager.gd`** — formation + spawning
  - 4-row formation: `[3, 4, 5, 8]` archers per row = 20 max slots.
  - 3 `starting_archers` pre-placed on ready.
  - `add_archer(base_dmg: int = 1)` → spawns archer in next available slot.
  - Node paths: `archer_container` → `../FortUnits`, `projectile_container` → `../Projectiles`.

### Projectile
- **`arrow.gd`** — projectile behavior (Area2D)
  - `speed = 500`, `damage = 1` (overridden by archer's `base_damage` on spawn).
  - Moves in `direction`. Auto-destroys off-screen or on enemy collision.

### Player Attack
- **`cursor_attack.gd`** — click attack
  - `damage = 1`, `radius = 55`, `cooldown = 0.18s`.
  - Action: `"click_attack"`. Doesn't click below `wall_y` (580) to protect friendly units.

### Fort Zone
- **`fort_zone.gd`** — fort HP logic
  - `max_health = 100`, `health` variable.
  - `take_damage(amount)` → reduces HP, emits `health_changed(current, max_health)`, emits `destroyed` at 0.
  - `main.gd` reads `health_changed` to update HUD label. `destroyed` pauses game permanently.

### Pickup
- **`pickup.gd`** — shared by CoinPickup and CrystalPickup
  - Waits for `delay` (0.25s), then drifts toward `target_position` at `speed = 220`.
  - On arrival (within 10px), emits `collected(pickup_type, value)`, then destroys.
  - Coins: `value = 1` → adds to `money` in main.
  - Crystals: `value = 2` → adds to `current_xp` in main.

### Level-Up System
- **`upgrade_pool.gd`** — data-driven upgrade definitions (plain Object, not a Node)
  - `get_all()` → array of upgrade dicts. 3 placeholders: `cursor_damage_up`, `archer_damage_up`, `fort_max_hp_up`.
  - `get_choices(n: int = 3)` → shuffles + returns `n` unique choices.
- **`level_up_overlay.gd`** — UI overlay (ColorRect with `PROCESS_MODE_ALWAYS` for paused operation)
  - `show_choices(choices)` → builds Button per choice.
  - `hide_overlay()` → clears buttons, hides.
  - Emits `upgrade_chosen(data: Dictionary)`.
  - **LevelUpOverlay.tscn** — scene tree: ColorRect > CenterContainer > VBoxContainer > TitleLabel + ChoicesContainer.

---

## Scene Files (prefabs)

| File | Type | Script | Description |
|------|------|--------|-------------|
| `Enemy.tscn` | Area2D + Collision + Polygon2D | `enemy.gd` | Red square enemy |
| `Archer.tscn` | Node2D + Polygon2D + Timer | `archer.gd` | Magenta archer unit |
| `Arrow.tscn` | Area2D + Collision + Polygon2D | `arrow.gd` | Cyan projectile |
| `CoinPickup.tscn` | Node2D + Polygon2D | `pickup.gd` | Yellow coin pickup |
| `Crystal_Pickup.tscn` | Node2D + Polygon2D | `pickup.gd` | Cyan crystal pickup |

All use simple colored `Polygon2D` as placeholder graphics.

---

## Signal Map

```
enemy.died(pos)         → enemy_spawner._on_enemy_died
  → spawns coin + crystal

pickup.collected(type,v)→ enemy_spawner._on_pickup_collected
  → forwards to main via enemy_spawner.pickup_collected

main._on_pickup_collected
  → coin: money += value
  → crystal: add_xp(value)

fort_zone.health_changed(current, max) → main._on_fort_health_changed → HUD update
fort_zone.destroyed     → main._on_fort_destroyed → permanent game-over pause

level_up_overlay.upgrade_chosen(data) → main._on_upgrade_chosen
  → applies upgrade, decrements pending, opens next or resumes
```

---

## Key Coordinates / Constants
| Value | Purpose |
|-------|---------|
| `wall_y = 580` | Divide battlefield from fort zone |
| `formation_anchor = (640, 650)` | Formation center point |
| `xp formula = 300 + (level-1) * 100` | XP threshold per level |

---

## How to Extend

- **Add upgrades:** Edit `get_all()` in `upgrade_pool.gd`, add `match` arm in `main.gd`'s `_apply_upgrade()`.
- **Add enemy types:** Create new `.tscn` with `enemy.gd` (or subclass), swap `enemy_scene` on EnemySpawner.
- **Add archer upgrades to future archers:** `archer_manager.add_archer()` accepts `base_dmg`, shared via `main.archer_damage_bonus`.
- **Change formation:** Modify `row_counts`, `row_widths`, `row_y_offsets` in `archer_manager.gd`.
