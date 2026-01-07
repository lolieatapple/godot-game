extends Node2D

# 准星配置
@export var crosshair_size: float = 20.0
@export var crosshair_thickness: float = 2.0
@export var crosshair_gap: float = 5.0
@export var crosshair_color: Color = Color(0, 1, 0, 0.8)  # 绿色半透明

func _ready():
	# 设置为始终处理模式，确保暂停时也能移动
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 隐藏系统鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# 设置为最高渲染层级
	z_index = 100

func _process(_delta):
	# 准星跟随鼠标位置
	global_position = get_global_mouse_position()
	queue_redraw()

func _draw():
	# 绘制准星（十字形）
	var half_size = crosshair_size / 2
	var gap = crosshair_gap

	# 上线
	draw_line(
		Vector2(0, -half_size),
		Vector2(0, -gap),
		crosshair_color,
		crosshair_thickness
	)

	# 下线
	draw_line(
		Vector2(0, gap),
		Vector2(0, half_size),
		crosshair_color,
		crosshair_thickness
	)

	# 左线
	draw_line(
		Vector2(-half_size, 0),
		Vector2(-gap, 0),
		crosshair_color,
		crosshair_thickness
	)

	# 右线
	draw_line(
		Vector2(gap, 0),
		Vector2(half_size, 0),
		crosshair_color,
		crosshair_thickness
	)

	# 中心点
	draw_circle(Vector2.ZERO, 1.5, crosshair_color)

func _exit_tree():
	# 恢复系统鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
