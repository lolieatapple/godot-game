extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var damage_overlay: ColorRect = $DamageOverlay
@onready var level_label: Label = $LevelLabel
@onready var kills_label: Label = $KillsLabel
@onready var level_complete_label: Label = $LevelCompleteLabel
@onready var start_label: Label = $StartLabel

var score: int = 0
var damage_overlay_alpha: float = 0.0
var damage_fade_speed: float = 2.0

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

	# Connect to LevelManager signals
	var level_manager = get_tree().get_first_node_in_group("LevelManager")
	if level_manager:
		level_manager.level_changed.connect(_on_level_changed)
		level_manager.kills_changed.connect(_on_kills_changed)
		level_manager.level_completed.connect(_on_level_completed)

		# 初始化显示
		_on_level_changed(level_manager.current_level)
		_on_kills_changed(level_manager.current_kills, level_manager.kills_per_level)

	# 隐藏通关提示和开始提示
	if level_complete_label:
		level_complete_label.visible = false
	if start_label:
		start_label.visible = false

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

func _process(delta: float) -> void:
	# 伤害遮罩渐隐效果
	if damage_overlay_alpha > 0:
		damage_overlay_alpha -= damage_fade_speed * delta
		damage_overlay_alpha = max(damage_overlay_alpha, 0)

		if damage_overlay_alpha > 0:
			damage_overlay.visible = true
			var overlay_color = damage_overlay.color
			overlay_color.a = damage_overlay_alpha
			damage_overlay.color = overlay_color
		else:
			damage_overlay.visible = false

func show_damage_effect() -> void:
	"""显示伤害效果（红色遮罩）"""
	damage_overlay_alpha = 0.5
	damage_overlay.visible = true

func _on_level_changed(level: int) -> void:
	"""关卡改变时更新显示"""
	if level_label:
		level_label.text = "Level: " + str(level)

func _on_kills_changed(kills: int, required: int) -> void:
	"""击杀数改变时更新显示"""
	if kills_label:
		kills_label.text = "Kills: " + str(kills) + "/" + str(required)

func _on_level_completed(level: int) -> void:
	"""关卡完成时显示提示"""
	if level_complete_label:
		level_complete_label.text = "Level " + str(level) + " Complete!"
		level_complete_label.visible = true

		# 2秒后隐藏
		await get_tree().create_timer(2.0, true, false, true).timeout
		level_complete_label.visible = false

func show_ready_text() -> void:
	"""显示 Ready 文字"""
	if start_label:
		start_label.text = "Ready"
		start_label.visible = true

func show_go_text() -> void:
	"""显示 Go! 文字"""
	if start_label:
		start_label.text = "Go!"
		start_label.visible = true

func hide_start_text() -> void:
	"""隐藏开始文字"""
	if start_label:
		start_label.visible = false
