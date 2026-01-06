extends CharacterBody2D

signal zombie_killed(points: int)

@export var speed: float = 150.0
@export var attack_range: float = 20.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var score_value: int = 10

var player: CharacterBody2D = null
var can_attack: bool = true
var attack_timer: float = 0.0

func _ready() -> void:
	# Find the player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

	# Connect to player's damage area
	var player_damage_areas = get_tree().get_nodes_in_group("Player")
	if player_damage_areas.size() > 0:
		var player_node = player_damage_areas[0]
		if player_node.has_node("DamageArea"):
			var damage_area = player_node.get_node("DamageArea")
			damage_area.body_entered.connect(_on_player_damage_area_entered)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# Handle attack cooldown
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

	var distance_to_player = global_position.distance_to(player.global_position)

	# Move towards player if not in attack range
	if distance_to_player > attack_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed

		# move_and_slide() automatically handles collision with other CharacterBody2D zombies
		move_and_slide()

		# Face the player
		look_at(player.global_position)
	else:
		# In attack range, stop moving and attack
		velocity = Vector2.ZERO
		look_at(player.global_position)

		# Attack player if in range and can attack
		if can_attack:
			attack_player()

func _on_player_damage_area_entered(body: Node2D) -> void:
	# When zombie enters player's damage area, start attacking
	if body == self and can_attack:
		attack_player()

func attack_player() -> void:
	if player == null or not can_attack:
		return

	can_attack = false
	attack_timer = attack_cooldown

	# Deal damage to player
	if player.has_method("take_damage"):
		player.take_damage(damage)

func die() -> void:
	# Emit signal before dying
	zombie_killed.emit(score_value)
	queue_free()
