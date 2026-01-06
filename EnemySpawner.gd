extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_distance_min: float = 500.0
@export var spawn_distance_max: float = 600.0

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

	# Spawn zombie at random position around player
	var zombie = zombie_scene.instantiate()

	# Random angle around the player
	var angle = randf() * TAU  # TAU = 2 * PI
	var distance = randf_range(spawn_distance_min, spawn_distance_max)

	# Calculate spawn position
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	zombie.global_position = player.global_position + spawn_offset

	# Add zombie to the scene (same parent as spawner)
	get_parent().add_child(zombie)
