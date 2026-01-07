extends Node2D

# 地板配置
@export var floor_size: Vector2 = Vector2(2000, 2000)
@export var floor_color: Color = Color(0.15, 0.15, 0.15)  # 深灰色地板
@export var grid_color: Color = Color(0.25, 0.25, 0.25)  # 网格线颜色
@export var grid_size: int = 64  # 网格大小（像素风格，64x64）
@export var grid_line_width: float = 1.0
@export var draw_grid: bool = true

func _ready():
	# 添加到 Floor 组，方便 LevelManager 查找
	add_to_group("Floor")
	queue_redraw()

func _draw():
	# 绘制地板底色
	draw_rect(Rect2(-floor_size / 2, floor_size), floor_color, true)

	# 绘制网格
	if draw_grid:
		var start_x = -floor_size.x / 2
		var start_y = -floor_size.y / 2
		var end_x = floor_size.x / 2
		var end_y = floor_size.y / 2

		# 垂直网格线
		var x = start_x
		while x <= end_x:
			draw_line(
				Vector2(x, start_y),
				Vector2(x, end_y),
				grid_color,
				grid_line_width
			)
			x += grid_size

		# 水平网格线
		var y = start_y
		while y <= end_y:
			draw_line(
				Vector2(start_x, y),
				Vector2(end_x, y),
				grid_color,
				grid_line_width
			)
			y += grid_size
