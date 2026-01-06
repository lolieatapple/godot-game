# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 game project using GL Compatibility rendering. The project is in early development with character and tile assets prepared but no scenes or scripts implemented yet.

### Game Design

**Genre**: Top-down Pixel Zombie Shooter
**Style**: 2D, Pixel Art
**Core Mechanics**:
- WASD movement
- Mouse aim
- Left click to shoot

**Entities**:
- Player (controllable character)
- Zombie (follows/chases player)
- Bullet (projectile)

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

- `assets/` - Game assets organized by type:
  - Character sprites in subdirectories (Hitman 1, Man Blue, Man Brown, Man Old, Robot 1, Soldier 1, Survivor 1, Woman Green, Zombie 1)
  - Each character folder contains animation sprites: `_gun.png`, `_hold.png`, `_machine.png`, `_reload.png`, `_silencer.png`, `_stand.png`
  - `Tiles/` - Environment tile sprites (tile_01.png through tile_524.png)
  - `weapon_*.png` - Weapon sprites (gun, machine, silencer)
- `.godot/` - Godot engine cache (ignored by git)
- `project.godot` - Godot project configuration file

## Asset Naming Conventions

Character sprites follow the pattern: `{character}_{action}.png`
- Actions: gun, hold, machine, reload, silencer, stand

Tile sprites follow the pattern: `tile_{number}.png` (numbered 01-524)

## Godot-Specific Development Notes

### File Organization
- Scripts should be placed alongside their scene files or in a dedicated `scripts/` directory
- Scenes (.tscn) should be organized by functionality (e.g., `scenes/characters/`, `scenes/levels/`)
- Resources (.tres) for reusable components like materials, animations, etc.

### Working with Assets
- All asset imports are auto-generated (.import files) - don't modify these manually
- Character sprites appear to be animation frames - consider using AnimatedSprite2D nodes
- Tile sprites are suitable for TileMap nodes or TileSet resources

### GDScript Conventions
- Use snake_case for variables and functions
- Use PascalCase for class names and node names
- Prefer signals over direct function calls for decoupling
- Use typed GDScript for better editor support: `var player: CharacterBody2D`

### Scene Structure
- Root node should match the purpose (Node2D for 2D games, Node3D for 3D, Control for UI)
- Group related nodes under parent nodes for organization
- Use unique names (%) for frequently accessed child nodes

## Rendering Configuration

The project uses GL Compatibility rendering method for both desktop and mobile, ensuring broad compatibility across platforms.
