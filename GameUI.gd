extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel

var score: int = 0

func _ready() -> void:
	# Connect to player signals
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_player_health_changed)

		# Initialize health bar
		if "max_health" in player and "health" in player:
			health_bar.max_value = player.max_health
			health_bar.value = player.health

	# Connect to zombie death signal from all zombies
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	# When a new zombie is added, connect to its death signal
	if node.is_in_group("Zombie") and node.has_signal("zombie_killed"):
		node.zombie_killed.connect(_on_zombie_killed)

func _on_player_health_changed(new_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = new_health

	# Change color based on health percentage
	var health_percent = new_health / max_health
	if health_percent > 0.6:
		health_bar.modulate = Color.GREEN
	elif health_percent > 0.3:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.RED

func _on_zombie_killed(points: int) -> void:
	score += points
	score_label.text = "Score: " + str(score)
