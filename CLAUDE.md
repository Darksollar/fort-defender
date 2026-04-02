# Project Overview
- Godot 4.6 desktop prototype for a top-down fort-defense game.
- Main loop: enemies spawn from the top, move downward, archers in the bottom fort zone auto-fire, the player uses cursor attack, enemies that reach the wall damage the fort zone, and dead enemies drop 1 coin + 1 crystal.
- Window size is 1280x720.

# Architecture Ground Truths
- The fort is the bottom zone, not a separate castle/building object.
- `FortZone` is the controller for fort-zone health and wall logic.
- Enemies stop at `wall_y` and attack `FortZone`; they should not disappear on wall contact unless explicitly requested.
- `CursorAttack` is part of the intended gameplay loop; do not remove or bypass it unless asked.
- Enemy loot is event-driven: `enemy.gd` emits `died(drop_position)`, and `enemy_spawner.gd` spawns 1 coin and 1 crystal.
- Pickups are currently `Node2D`, not `Area2D`, because they drift to the fort zone and do not use collision yet.
- Keep current node names/paths stable unless the task is explicitly a refactor (`MainNode2D`, `WorldNode2D`, `FortZone`, `FortUnits`, `Enemies`, `Projectiles`, `Pickups`, `HUD`).
- Files are currently in the project root. Do not reorganize the repo into new folders unless explicitly asked.

# Current Prototype Status
- Working now: enemy spawning, enemy movement, archer auto-fire, arrow hits, cursor attack, fort-zone HP, enemy wall attack, game-over pause on fort destruction, and coin/crystal drops that travel to the fort zone.
- Not implemented yet: real resource counters, XP/leveling, buy-archer loop, archer formation system, enemy lane/spacing system, and art/polish.

# Code Style
- Use GDScript.
- Prefer small, direct scripts over premature abstraction.
- Keep exported variables for gameplay tuning (`@export`) when values are likely to be adjusted in the editor.
- Preserve typed parameters/returns where already used.
- Match existing naming and scene wiring patterns before inventing new ones.
- Do not introduce big architecture changes, autoload singletons, or new manager scenes unless the task clearly requires them.

# Workflow Rules
- For small scoped fixes, edit directly.
- For multi-file or architectural changes, first inspect the relevant scenes/scripts, then make a short plan, then implement.
- Keep changes minimal and prototype-first. Prefer making the loop work before polishing visuals.
- Do not hand-wave verification. Say clearly what was actually checked.
- If a requested change would conflict with the current game model, call it out before coding.
- When adding more archers later, prefer a formation/layout system over hand-authored marker coordinates.

# Verification
- There is currently no automated test suite.
- Primary verification is manual gameplay validation in Godot.
- After gameplay changes, verify the relevant loop actually works in-game. For the current prototype, check:
  1. enemies spawn at the top and move downward
  2. archers auto-fire and arrows hit
  3. cursor attack damages enemies
  4. enemies reaching the wall damage the fort zone instead of vanishing
  5. enemy death drops 1 coin and 1 crystal
  6. pickups move toward the fort zone
  7. fort destruction pauses the game
- If something was not run or could not be verified, say so explicitly.

# Useful Commands
- Search code: `rg -n "pattern" .`
- List project scripts/scenes: `find . -maxdepth 1 \( -name "*.gd" -o -name "*.tscn" \) | sort`
