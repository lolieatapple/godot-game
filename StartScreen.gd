extends Control

func _ready():
	# 简单的闪烁动画
	var tween = create_tween().set_loops()
	tween.tween_property($PressKeyLabel, "modulate:a", 0.0, 1.0)
	tween.tween_property($PressKeyLabel, "modulate:a", 1.0, 1.0)

func _input(event):
	if event is InputEventKey and event.pressed:
		start_game()
	elif event is InputEventMouseButton and event.pressed:
		start_game()
	elif event is InputEventJoypadButton and event.pressed:
		start_game()

func start_game():
	# 防止多次触发
	set_process_input(false)
	# 切换到主场景
	get_tree().change_scene_to_file("res://Main.tscn")
