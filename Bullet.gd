extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect to body entered signal to detect hits
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Hit something, check what it is
	if body.is_in_group("Zombie"):
		# Hit a zombie, kill it
		if body.has_method("die"):
			body.die()  # Call zombie's die method to emit signal
		else:
			body.queue_free()  # Fallback
	# Remove the bullet regardless of what it hit (zombie or wall)
	queue_free()

func _on_screen_exited() -> void:
	# Remove bullet when it leaves the screen
	queue_free()
