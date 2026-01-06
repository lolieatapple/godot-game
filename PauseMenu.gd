extends CanvasLayer

func _ready() -> void:
	# 初始隐藏暂停菜单
	hide()

func _input(event: InputEvent) -> void:
	# 按ESC键切换暂停状态
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	"""切换暂停/继续游戏"""
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused

	if is_paused:
		show()
	else:
		hide()

func _on_resume_button_pressed() -> void:
	"""继续游戏"""
	toggle_pause()

func _on_restart_button_pressed() -> void:
	"""重新开始游戏"""
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	"""退出游戏"""
	get_tree().quit()
