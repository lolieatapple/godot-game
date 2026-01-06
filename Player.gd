extends CharacterBody2D

@export var speed: float = 300.0
@export var shoot_cooldown: float = 0.2

@onready var gun_tip: Marker2D = $GunTip

var bullet_scene: PackedScene = preload("res://Bullet.tscn")
var can_shoot: bool = true
var cooldown_timer: float = 0.0

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

func shoot() -> void:
	can_shoot = false
	cooldown_timer = shoot_cooldown

	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = gun_tip.global_position
	bullet.direction = (get_global_mouse_position() - gun_tip.global_position).normalized()
	bullet.rotation = rotation

	# Add bullet to the scene
	get_parent().add_child(bullet)
