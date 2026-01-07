extends Node

# 关卡配置
@export var kills_per_level: int = 10

# 当前关卡状态
var current_level: int = 1
var current_kills: int = 0

# 信号
signal level_changed(level: int)
signal kills_changed(kills: int, required: int)
signal level_completed(level: int)

# 关卡配色方案
var level_colors = {
	1: {
		"floor": Color(0.15, 0.15, 0.15),       # 深灰色
		"grid": Color(0.25, 0.25, 0.25),        # 浅灰网格
		"wall": Color(0.4, 0.3, 0.25),          # 棕灰色
		"wall_border": Color(0.2, 0.15, 0.1),   # 深棕色边框
		"zombie": Color(0.8, 1.0, 0.8)          # 浅绿色僵尸
	},
	2: {
		"floor": Color(0.1, 0.15, 0.2),         # 深蓝灰色
		"grid": Color(0.2, 0.25, 0.3),          # 蓝灰网格
		"wall": Color(0.25, 0.35, 0.45),        # 蓝色墙
		"wall_border": Color(0.1, 0.2, 0.3),    # 深蓝边框
		"zombie": Color(0.7, 0.8, 1.0)          # 淡蓝色僵尸
	},
	3: {
		"floor": Color(0.15, 0.1, 0.15),        # 深紫灰色
		"grid": Color(0.25, 0.2, 0.25),         # 紫灰网格
		"wall": Color(0.4, 0.25, 0.35),         # 紫色墙
		"wall_border": Color(0.2, 0.1, 0.2),    # 深紫边框
		"zombie": Color(1.0, 0.7, 1.0)          # 粉紫色僵尸
	},
	4: {
		"floor": Color(0.15, 0.12, 0.08),       # 深棕色
		"grid": Color(0.25, 0.2, 0.15),         # 棕色网格
		"wall": Color(0.45, 0.35, 0.2),         # 土黄色墙
		"wall_border": Color(0.25, 0.18, 0.1),  # 深土黄边框
		"zombie": Color(1.0, 0.9, 0.6)          # 土黄色僵尸
	},
	5: {
		"floor": Color(0.08, 0.15, 0.1),        # 深绿灰色
		"grid": Color(0.15, 0.25, 0.18),        # 绿灰网格
		"wall": Color(0.2, 0.4, 0.25),          # 绿色墙
		"wall_border": Color(0.1, 0.2, 0.12),   # 深绿边框
		"zombie": Color(0.6, 1.0, 0.7)          # 明绿色僵尸
	},
	6: {
		"floor": Color(0.18, 0.08, 0.08),       # 深红灰色
		"grid": Color(0.28, 0.15, 0.15),        # 红灰网格
		"wall": Color(0.45, 0.2, 0.2),          # 红色墙
		"wall_border": Color(0.25, 0.1, 0.1),   # 深红边框
		"zombie": Color(1.0, 0.6, 0.6)          # 淡红色僵尸
	},
	7: {
		"floor": Color(0.12, 0.12, 0.18),       # 深靛蓝色
		"grid": Color(0.22, 0.22, 0.3),         # 靛蓝网格
		"wall": Color(0.3, 0.3, 0.5),           # 靛蓝墙
		"wall_border": Color(0.15, 0.15, 0.3),  # 深靛蓝边框
		"zombie": Color(0.8, 0.8, 1.0)          # 靛蓝色僵尸
	},
	8: {
		"floor": Color(0.18, 0.15, 0.08),       # 深橙棕色
		"grid": Color(0.28, 0.24, 0.15),        # 橙棕网格
		"wall": Color(0.5, 0.4, 0.2),           # 橙色墙
		"wall_border": Color(0.3, 0.22, 0.1),   # 深橙边框
		"zombie": Color(1.0, 0.8, 0.5)          # 橙色僵尸
	},
	9: {
		"floor": Color(0.08, 0.12, 0.15),       # 深青灰色
		"grid": Color(0.15, 0.22, 0.25),        # 青灰网格
		"wall": Color(0.2, 0.35, 0.4),          # 青色墙
		"wall_border": Color(0.1, 0.2, 0.25),   # 深青边框
		"zombie": Color(0.6, 0.9, 1.0)          # 青色僵尸
	},
	10: {
		"floor": Color(0.05, 0.05, 0.05),       # 极深灰（最终关）
		"grid": Color(0.15, 0.15, 0.15),        # 暗灰网格
		"wall": Color(0.5, 0.5, 0.5),           # 银色墙
		"wall_border": Color(0.2, 0.2, 0.2),    # 深灰边框
		"zombie": Color(1.0, 1.0, 1.0)          # 白色僵尸（最终关）
	}
}

# 关卡剧情对话
var level_dialogues = {
	1: "Year 2035. The virus took everything.\nI have the antibodies. I must survive.\nFirst, secure this safehouse.",
	2: "Supplies are running low.\nI saw a grocery store nearby.\nNeed to find food before I starve.",
	3: "Thirsty... so thirsty.\nThe city water is contaminated.\nMust find bottled water in the warehouse.",
	4: "Got a nasty cut on my leg.\nInfection risk is high.\nNeed antibiotics from the pharmacy.",
	5: "Radio silence for weeks.\nThere's a broadcast tower ahead.\nMaybe I can reach other survivors.",
	6: "They swarm in larger groups now.\nFound an old police station.\nNeed ammo. Lots of it.",
	7: "The mutation is spreading.\nFaster, stronger zombies.\nNeed to find a vehicle to keep moving.",
	8: "Winter is coming.\nNights are freezing.\nNeed to find warm clothes and fuel.",
	9: "Heard a signal! A military outpost?\nIt's far, through the city center.\nThis will be a tough fight.",
	10: "The signal was a trap... or a grave.\nNo one is left here.\nI am the last hope. I keep fighting."
}

func _ready():
	# 连接到所有僵尸的死亡信号
	get_tree().node_added.connect(_on_node_added)

	# 初始化第一关
	apply_level_colors()

	# 等待场景完全加载后生成初始迷宫
	await get_tree().process_frame
	var maze_generator = get_tree().get_first_node_in_group("MazeGenerator")
	if maze_generator:
		maze_generator.generate_maze()
	
	# 显示第一关对话和开始动画
	start_level_sequence()

func start_level_sequence():
	# 暂停游戏
	get_tree().paused = true
	
	# 1. 显示剧情对话
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui:
		var dialogue = level_dialogues.get(current_level, "Still alive.\nThe horde never ends.\nMust keep moving.")
		game_ui.show_dialogue(dialogue)
		
		# 等待对话结束
		await game_ui.dialogue_finished
	
	# 2. 显示 Ready, Go!
	await show_level_start_animation()

func _on_node_added(node: Node):
	# 当新节点加入场景树时，检查是否是僵尸
	if node.is_in_group("Zombie"):
		# 连接僵尸的死亡信号
		if node.has_signal("zombie_killed"):
			node.zombie_killed.connect(_on_zombie_killed)

func _on_zombie_killed(points: int):
	current_kills += 1
	kills_changed.emit(current_kills, kills_per_level)

	# 检查是否完成关卡
	if current_kills >= kills_per_level:
		complete_level()

func complete_level():
	# 暂停游戏
	get_tree().paused = true

	level_completed.emit(current_level)

	# 等待一小段时间后进入下一关（使用 process_always 模式的计时器）
	await get_tree().create_timer(2.0, true, false, true).timeout

	# 进入下一关
	next_level()

func next_level():
	current_level += 1
	current_kills = 0

	level_changed.emit(current_level)
	kills_changed.emit(current_kills, kills_per_level)

	# 应用新关卡颜色
	apply_level_colors()

	# 清除所有现存僵尸
	clear_zombies()

	# 显示剧情对话和开始动画
	await start_level_sequence()

func show_level_start_animation():
	"""显示关卡开始动画：Ready -> Go!"""
	# 保持暂停状态
	get_tree().paused = true

	# 获取 GameUI
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui:
		# 显示 "Ready"
		game_ui.show_ready_text()
		await get_tree().create_timer(1.0, true, false, true).timeout

		# 显示 "Go!"
		game_ui.show_go_text()
		await get_tree().create_timer(1.0, true, false, true).timeout

		# 隐藏文字
		game_ui.hide_start_text()

	# 恢复游戏
	get_tree().paused = false

func apply_level_colors():
	# 获取当前关卡的配色（如果超过定义的关卡数，循环使用）
	var level_key = ((current_level - 1) % level_colors.size()) + 1
	var colors = level_colors[level_key]

	# 更新地板颜色
	var floor = get_tree().get_first_node_in_group("Floor")
	if floor:
		floor.floor_color = colors["floor"]
		floor.grid_color = colors["grid"]
		floor.queue_redraw()

	# 更新所有墙体颜色（外围墙壁）
	var walls = get_tree().get_nodes_in_group("Wall")
	for wall in walls:
		wall.wall_color = colors["wall"]
		wall.border_color = colors["wall_border"]
		if wall.has_node("Visual"):
			wall.get_node("Visual").queue_redraw()

	# 重新生成迷宫墙壁
	var maze_generator = get_tree().get_first_node_in_group("MazeGenerator")
	if maze_generator:
		maze_generator.regenerate_maze()

func clear_zombies():
	# 清除场景中所有僵尸
	var zombies = get_tree().get_nodes_in_group("Zombie")
	for zombie in zombies:
		zombie.queue_free()

func get_current_level() -> int:
	return current_level

func get_current_kills() -> int:
	return current_kills

func get_kills_required() -> int:
	return kills_per_level

func get_zombie_color() -> Color:
	"""获取当前关卡的僵尸颜色"""
	var level_key = ((current_level - 1) % level_colors.size()) + 1
	var colors = level_colors[level_key]
	return colors["zombie"]

func get_zombie_stats() -> Dictionary:
	"""获取当前关卡的僵尸属性（血量和速度）"""
	# 基础属性
	var base_health = 50.0
	var base_speed = 100.0

	# 每关增加的属性
	var health_per_level = 20.0  # 每关增加20血量
	var speed_per_level = 15.0   # 每关增加15速度

	# 计算当前关卡的属性
	var level_multiplier = current_level - 1
	var current_health = base_health + (health_per_level * level_multiplier)
	var current_speed = base_speed + (speed_per_level * level_multiplier)

	return {
		"health": current_health,
		"speed": current_speed
	}
