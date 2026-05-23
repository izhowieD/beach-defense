# Beach Defense

Godot 4.x third-person turret shooter prototype.

## Gameplay

- Move the mouse to rotate the turret barrel horizontally and vertically.
- Rotation is clamped to 60 degrees from center.
- The turret fires shells automatically.
- Enemies spawn randomly in front of the turret and move toward it.
- Red enemies are fast and die from one shell hit.
- Purple enemies are slower and die from two shell hits.
- Destroying an enemy adds 1 score.
- An enemy touching the turret reduces turret health.
- The HUD shows health and score in real time.
- Press `Esc` to release or recapture the mouse.

## Main Files

- `scenes/Main.tscn` starts the game.
- `scripts/Main.gd` builds the world, HUD, spawner, health, and score.
- `scripts/Turret.gd` handles mouse aiming and automatic shooting.
- `scripts/Projectile.gd` handles shell movement and lifetime.
- `scripts/Enemy.gd` handles enemy movement, hit detection, scoring, and turret damage.
