extends CharacterBody2D

signal zombie_killed(points: int)

@export var speed: float = 100.0  # 降低初始速度
@export var attack_range: float = 40.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var score_value: int = 10
@export var max_health: float = 50.0  # 初始血量

var player: CharacterBody2D = null
var can_attack: bool = true
var attack_timer: float = 0.0
var health: float = 50.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

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

	# 应用当前关卡的僵尸颜色
	apply_level_color()

	# 从 LevelManager 获取当前关卡的僵尸属性
	apply_level_stats()

	# 初始化血条
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

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
		
		# 检查是否撞到了玩家（处理贴脸伤害）
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == player and can_attack:
				attack_player()
				break

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

func take_damage(amount: float) -> void:
	"""僵尸受到伤害"""
	health -= amount

	# 更新血条
	if health_bar:
		health_bar.value = health

	# 检查是否死亡
	if health <= 0:
		die()

func die() -> void:
	# Emit signal before dying
	zombie_killed.emit(score_value)
	queue_free()

func apply_level_color() -> void:
	"""从 LevelManager 获取并应用当前关卡的僵尸颜色"""
	var level_manager = get_tree().get_first_node_in_group("LevelManager")
	if level_manager and sprite:
		var zombie_color = level_manager.get_zombie_color()
		sprite.modulate = zombie_color

func apply_level_stats() -> void:
	"""从 LevelManager 获取并应用当前关卡的僵尸属性"""
	var level_manager = get_tree().get_first_node_in_group("LevelManager")
	if level_manager:
		var stats = level_manager.get_zombie_stats()
		max_health = stats["health"]
		speed = stats["speed"]

func set_zombie_color(color: Color) -> void:
	"""直接设置僵尸颜色"""
	if sprite:
		sprite.modulate = color
