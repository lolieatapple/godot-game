# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 game project using GL Compatibility rendering. The game is a top-down pixel zombie shooter with core gameplay systems implemented.

### Game Design

**Genre**: Top-down Pixel Zombie Shooter
**Style**: 2D, Pixel Art
**Core Mechanics**:
- WASD movement
- Mouse aim
- Left click to shoot

**Implemented Systems**:
- Player character with health and shooting mechanics
- Zombie AI with pathfinding and attack behavior
- Automatic enemy spawning system
- Camera shake effects for visual feedback
- Score tracking and health UI
- Bullet collision and damage system

## Development Commands

### Opening the Project
```bash
# Open in Godot Editor (if godot is in PATH)
godot --editor .

# Or specify the project file
godot --editor project.godot
```

### Running the Game
```bash
# Run the main scene (once configured)
godot .
```

### Exporting
```bash
# Export using a preset
godot --export-release "preset_name" output_path
```

## Project Structure

### Core Files (Root Directory)
- `Main.tscn` - Main game scene containing the tilemap, player spawn, enemy spawner, and UI
- `Player.gd` / `Player.tscn` - Player character with movement, shooting, health, and damage
- `Zombie.gd` / `Zombie.tscn` - Enemy AI with chase behavior and attack logic
- `Bullet.gd` / `Bullet.tscn` - Projectile with collision detection
- `EnemySpawner.gd` - Spawns zombies at intervals around the player
- `CameraShake.gd` - Camera shake effect script (attached to Camera2D node in Player)
- `GameUI.gd` / `GameUI.tscn` - HUD showing health bar and score

### Assets
- `assets/` - Game assets organized by type:
  - Character sprites in subdirectories (Hitman 1, Man Blue, Man Brown, Man Old, Robot 1, Soldier 1, Survivor 1, Woman Green, Zombie 1)
  - Each character folder contains animation sprites: `_gun.png`, `_hold.png`, `_machine.png`, `_reload.png`, `_silencer.png`, `_stand.png`
  - `Tilesheet/` - Environment tilesheet for the game world
  - `weapon_*.png` - Weapon sprites (gun, machine, silencer)
- `.godot/` - Godot engine cache (ignored by git)
- `project.godot` - Godot project configuration file

## Architecture Overview

### Signal-Based Communication
The game uses Godot's signal system for decoupled communication:
- **Player → GameUI**: `health_changed(new_health, max_health)` signal updates the health bar
- **Zombie → GameUI**: `zombie_killed(points)` signal updates the score when zombies die
- **GameUI**: Listens to `node_added` tree signal to automatically connect to new zombies

### Node Groups
- `"Player"` - Player character (used by zombies and UI to find the player)
- `"Zombie"` - Enemy entities (used by bullets to detect hits)

### Key Systems

**Player System** (Player.gd):
- CharacterBody2D with WASD movement normalized for diagonal speed
- Mouse-based look_at() rotation and shooting
- Cooldown-based shooting with bullet instantiation
- Health system with damage taking and death (scene reload)
- Animation priority: shoot > walk > idle
- Camera shake on shoot via Camera2D child node with CameraShake.gd script
- DamageArea (Area2D) for detecting zombie contact

**Zombie AI** (Zombie.gd):
- CharacterBody2D that finds player via "Player" group in _ready()
- Chase behavior: moves toward player when beyond attack_range
- Attack behavior: stops and attacks when within attack_range
- Cooldown-based damage dealing via player.take_damage()
- Connects to player's DamageArea for collision-based attacks
- Emits zombie_killed signal before queue_free() for score tracking

**Spawning System** (EnemySpawner.gd):
- Node2D with Timer child node
- Spawns zombies at random angles around player position
- Spawn distance randomized between spawn_distance_min and spawn_distance_max
- Requires zombie_scene PackedScene export to be assigned in editor

**Bullet System** (Bullet.gd):
- Area2D with body_entered signal
- Linear movement via position += direction * speed * delta
- On collision: calls die() on zombies (not queue_free) to emit signals properly
- Auto-removes on screen exit or collision

**UI System** (GameUI.gd):
- CanvasLayer with HealthBar (ProgressBar) and ScoreLabel (Label)
- Finds player via "Player" group and connects to health_changed signal
- Dynamically connects to zombie_killed signals as new zombies spawn
- Health bar color changes: green > 60%, yellow > 30%, red ≤ 30%

**Camera Effects** (CameraShake.gd):
- Attached to Camera2D node in Player scene
- shake(intensity, duration) method called from Player.shoot()
- Gradually decreasing random offset based on remaining time
- Resets offset to Vector2.ZERO when complete

## Input Configuration

Custom input actions defined in project.godot:
- `move_left` - A key (physical_keycode 65)
- `move_right` - D key (physical_keycode 68)
- `move_up` - W key (physical_keycode 87)
- `move_down` - S key (physical_keycode 83)
- Shooting uses MOUSE_BUTTON_LEFT directly

## GDScript Conventions

- Use snake_case for variables and functions
- Use PascalCase for class names and node names
- Use typed GDScript: `var player: CharacterBody2D`
- Use @export for inspector-editable properties
- Use @onready for node references
- Prefer signals over direct function calls for cross-entity communication
- Use groups for finding entities dynamically

## Rendering Configuration

The project uses GL Compatibility rendering method for both desktop and mobile, ensuring broad compatibility across platforms.
