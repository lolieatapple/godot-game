extends CharacterBody2D

signal health_changed(new_health: float, max_health: float)

@export var speed: float = 300.0
@export var shoot_cooldown: float = 0.2
@export var max_health: float = 100.0

@onready var gun_tip: Marker2D = $GunTip
@onready var damage_area: Area2D = $DamageArea
@onready var camera: Camera2D = $Camera2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var bullet_scene: PackedScene = preload("res://Bullet.tscn")
var can_shoot: bool = true
var cooldown_timer: float = 0.0
var health: float = 100.0
var is_shooting: bool = false

func _physics_process(delta: float) -> void:
	# Handle movement with WASD
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalize to prevent faster diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	# Handle mouse aiming and rotation
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)

	# Handle shooting cooldown
	if not can_shoot:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_shoot = true

	# Handle shooting
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		shoot()

	# Handle animations
	update_animation()

func shoot() -> void:
	can_shoot = false
	cooldown_timer = shoot_cooldown
	is_shooting = true

	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = gun_tip.global_position
	bullet.direction = (get_global_mouse_position() - gun_tip.global_position).normalized()
	bullet.rotation = rotation

	# Add bullet to the scene
	get_parent().add_child(bullet)

	# Trigger camera shake for recoil effect
	if camera and camera.has_method("shake"):
		camera.shake(3.0, 0.1)  # intensity: 3.0, duration: 0.1 seconds

	# Play shoot animation
	if animated_sprite:
		animated_sprite.play("shoot")
		# Reset shooting flag when animation finishes
		await animated_sprite.animation_finished
		is_shooting = false

func update_animation() -> void:
	if not animated_sprite:
		return

	# Priority 1: Shoot animation (don't interrupt)
	if is_shooting:
		return

	# Priority 2: Walk animation when moving
	if velocity.length() > 0:
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	# Priority 3: Idle animation when stationary
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func take_damage(amount: float) -> void:
	health -= amount
	health = max(health, 0)  # Clamp to 0
	print("Player took %d damage. Health: %d" % [amount, health])

	# Emit signal for UI update
	health_changed.emit(health, max_health)

	if health <= 0:
		die()

func die() -> void:
	print("Game Over")
	get_tree().reload_current_scene()
