extends CharacterBody2D

@export var speed: float = 150.0
@export var attack_range: float = 20.0
@export var separation_force: float = 50.0

var player: CharacterBody2D = null

func _ready() -> void:
	# Find the player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	# Move towards player if not in attack range
	if distance_to_player > attack_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed

		# Apply separation from other zombies to prevent overlap
		var separation = get_separation_vector()
		velocity += separation * separation_force

		move_and_slide()

		# Face the player
		look_at(player.global_position)
	else:
		# In attack range, stop moving
		velocity = Vector2.ZERO
		look_at(player.global_position)

func get_separation_vector() -> Vector2:
	var separation = Vector2.ZERO
	var nearby_zombies = get_tree().get_nodes_in_group("Zombie")

	for zombie in nearby_zombies:
		if zombie == self:
			continue

		var distance = global_position.distance_to(zombie.global_position)
		if distance < 30.0 and distance > 0:
			var direction = (global_position - zombie.global_position).normalized()
			separation += direction / distance

	return separation
