extends Camera2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0

func _ready() -> void:
	rng.randomize()

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta

		# Calculate shake intensity based on remaining time
		var current_intensity = shake_intensity * (shake_timer / shake_duration)

		# Apply random offset
		offset.x = rng.randf_range(-current_intensity, current_intensity)
		offset.y = rng.randf_range(-current_intensity, current_intensity)
	else:
		# Reset offset when shake is done
		offset = Vector2.ZERO

func shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
