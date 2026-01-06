extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect to body entered signal to detect hits
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Hit something, remove the bullet
	if body.is_in_group("Zombie"):
		body.queue_free()  # Kill the zombie
	queue_free()  # Remove the bullet

func _on_screen_exited() -> void:
	# Remove bullet when it leaves the screen
	queue_free()
