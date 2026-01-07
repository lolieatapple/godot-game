extends Node2D

# 迷宫配置
@export var grid_size: int = 128  # 网格大小
@export var wall_density: float = 0.15  # 墙壁密度（0-1）
@export var min_wall_size: Vector2 = Vector2(128, 128)  # 最小墙壁尺寸
@export var max_wall_size: Vector2 = Vector2(384, 128)  # 最大墙壁尺寸
@export var safe_radius: float = 300.0  # 玩家出生点周围的安全半径

# 地图边界
@export var map_min: Vector2 = Vector2(-900, -900)
@export var map_max: Vector2 = Vector2(900, 900)

# 墙壁场景（使用 Wall.gd）
var wall_scene: PackedScene

# 存储所有生成的墙壁
var generated_walls: Array[Node] = []

func _ready():
	# 添加到组方便 LevelManager 查找
	add_to_group("MazeGenerator")

func generate_maze():
	"""生成新的迷宫布局"""
	# 清除旧墙壁
	clear_maze()

	# 获取玩家位置
	var player_pos = Vector2.ZERO
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_pos = players[0].global_position

	# 计算网格数量
	var grid_width = int((map_max.x - map_min.x) / grid_size)
	var grid_height = int((map_max.y - map_min.y) / grid_size)

	# 生成随机墙壁
	for x in range(grid_width):
		for y in range(grid_height):
			# 随机决定是否在这个网格位置生成墙壁
			if randf() < wall_density:
				var grid_pos = Vector2(
					map_min.x + x * grid_size,
					map_min.y + y * grid_size
				)

				# 检查是否太靠近玩家出生点
				if grid_pos.distance_to(player_pos) < safe_radius:
					continue

				# 随机墙壁方向（水平或垂直）
				var is_horizontal = randf() < 0.5

				# 随机墙壁长度
				var wall_length = randf_range(min_wall_size.x, max_wall_size.x)

				var wall_size: Vector2
				if is_horizontal:
					wall_size = Vector2(wall_length, 40)
				else:
					wall_size = Vector2(40, wall_length)

				# 创建墙壁
				create_wall(grid_pos + Vector2(grid_size / 2, grid_size / 2), wall_size)

func create_wall(position: Vector2, size: Vector2):
	"""在指定位置创建一个墙壁"""
	# 创建 StaticBody2D（墙壁）
	var wall = StaticBody2D.new()
	wall.add_to_group("MazeWall")
	wall.global_position = position

	# 创建碰撞形状
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape
	wall.add_child(collision_shape)

	# 创建可视化节点
	var visual = Node2D.new()
	visual.name = "Visual"
	wall.add_child(visual)

	# 获取当前关卡的墙壁颜色
	var level_manager = get_tree().get_first_node_in_group("LevelManager")
	var wall_color = Color(0.4, 0.3, 0.25)
	var border_color = Color(0.2, 0.15, 0.1)

	if level_manager:
		var level = level_manager.current_level
		var level_key = ((level - 1) % level_manager.level_colors.size()) + 1
		var colors = level_manager.level_colors[level_key]
		wall_color = colors["wall"]
		border_color = colors["wall_border"]

	# 连接绘制信号
	visual.draw.connect(func():
		# 绘制墙面主体
		visual.draw_rect(
			Rect2(-size / 2, size),
			wall_color,
			true
		)
		# 绘制边框
		visual.draw_rect(
			Rect2(-size / 2, size),
			border_color,
			false,
			2.0
		)
	)

	# 添加到场景
	get_parent().add_child(wall)
	visual.queue_redraw()

	# 保存引用
	generated_walls.append(wall)

func clear_maze():
	"""清除所有生成的墙壁"""
	for wall in generated_walls:
		if is_instance_valid(wall):
			wall.queue_free()
	generated_walls.clear()

func regenerate_maze():
	"""重新生成迷宫（关卡切换时调用）"""
	# 等待一帧确保场景已更新
	await get_tree().process_frame
	generate_maze()
