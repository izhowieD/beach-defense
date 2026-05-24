# Beach Defense

Godot 4.x third-person turret shooter prototype.

## Gameplay

- Move the mouse to rotate the turret barrel horizontally and vertically.
- Horizontal rotation is clamped to 60 degrees from center.
- Vertical rotation is clamped from wall-height horizontal aim down to 90 degrees.
- The turret fires shells automatically.
- The player fires from the top of a high castle wall toward enemies outside the gate.
- Enemies spawn inside the same fan-shaped fire arc that the turret can aim at.
- Enemies spawn from the far edge of the map at configurable left, center, or right lanes.
- Enemies stay clamped inside that playable fire arc while moving toward the wall-front target point.
- Red enemies are fast and die from one shell hit.
- Purple enemies are slower and die from two shell hits.
- Destroying an enemy adds 1 score.
- An enemy touching the turret reduces turret health.
- The HUD shows health and score in real time.
- Press `Esc` to release or recapture the mouse.

## Main Files

- `scenes/Main.tscn` starts the game.
- `scripts/Main.gd` loads the active level and owns global HUD, health, and score.
- `assets/levels/level_1.tscn` contains the first playable level.
- `assets/levels/level_1.gd` builds level 1's map, turret, spawner, and enemy play area.
- `scripts/Turret.gd` handles mouse aiming and automatic shooting.
- `scripts/Projectile.gd` handles shell movement and lifetime.
- `scripts/Enemy.gd` handles enemy movement, hit detection, scoring, and turret damage.
- `assets/enemies/*.tscn` contains editable enemy scene assets.
- `assets/projectiles/projectile_shell.tscn` contains the editable shell asset.
- `assets/turrets/turret_player.tscn` contains the editable player turret asset.
- `assets/levels/castle_wall.tscn` contains the editable castle wall asset.
- `assets/levels/outside_battlefield.tscn` contains the fan-shaped outside battlefield asset.
