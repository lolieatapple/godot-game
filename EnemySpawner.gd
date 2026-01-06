extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_distance_min: float = 500.0
@export var spawn_distance_max: float = 600.0
@export var max_spawn_attempts: int = 10

@onready var spawn_timer: Timer = $SpawnTimer

var player: Node2D = null

func _ready() -> void:
	# Find the player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

	# Setup timer
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if zombie_scene == null:
		push_warning("EnemySpawner: zombie_scene is not assigned!")
		return

	if player == null:
		return

	# Try to find a valid spawn position
	var spawn_position = find_valid_spawn_position()
	if spawn_position == Vector2.ZERO:
		# No valid position found, skip this spawn
		return

	# Spawn zombie at the valid position
	var zombie = zombie_scene.instantiate()
	zombie.global_position = spawn_position

	# Add zombie to the scene (same parent as spawner)
	get_parent().add_child(zombie)

func find_valid_spawn_position() -> Vector2:
	var space_state = get_world_2d().direct_space_state

	# Try multiple times to find a valid position
	for i in range(max_spawn_attempts):
		# Random angle around the player
		var angle = randf() * TAU  # TAU = 2 * PI
		var distance = randf_range(spawn_distance_min, spawn_distance_max)

		# Calculate spawn position
		var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
		var test_position = player.global_position + spawn_offset

		# Check if this position is valid (not colliding with walls)
		if is_position_valid(test_position, space_state):
			return test_position

	# No valid position found after max attempts
	return Vector2.ZERO

func is_position_valid(position: Vector2, space_state: PhysicsDirectSpaceState2D) -> bool:
	# Create a shape query to check for collisions
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = 1  # Check collision with layer 1 (walls/static objects)

	# Query the space
	var result = space_state.intersect_point(query, 1)

	# Position is valid if there are no collisions
	return result.size() == 0
