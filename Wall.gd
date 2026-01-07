extends StaticBody2D

# 墙面配置
@export var wall_size: Vector2 = Vector2(100, 100)
@export var wall_color: Color = Color(0.4, 0.3, 0.25)  # 棕灰色墙面
@export var border_color: Color = Color(0.2, 0.15, 0.1)  # 深色边框
@export var border_width: float = 2.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

func _ready():
	# 添加到 Wall 组，方便 LevelManager 查找
	add_to_group("Wall")

	# 设置碰撞形状大小
	if collision_shape:
		var shape = RectangleShape2D.new()
		shape.size = wall_size
		collision_shape.shape = shape

	# 连接 Visual 节点的 draw 信号
	if visual:
		visual.draw.connect(_draw_visual)
		visual.queue_redraw()

func _draw_visual():
	# 绘制墙面主体
	visual.draw_rect(
		Rect2(-wall_size / 2, wall_size),
		wall_color,
		true
	)

	# 绘制边框
	visual.draw_rect(
		Rect2(-wall_size / 2, wall_size),
		border_color,
		false,
		border_width
	)
