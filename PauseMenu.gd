extends CanvasLayer

@onready var title_label: Label = $Panel/CenterContainer/VBoxContainer/Title
@onready var resume_button: Button = $Panel/CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Panel/CenterContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# 初始隐藏暂停菜单
	hide()
	
	# 连接语言改变信号
	LocalizationManager.language_changed.connect(_update_text)
	_update_text()

func _update_text() -> void:
	if title_label:
		title_label.text = LocalizationManager.get_text("paused")
	if resume_button:
		resume_button.text = LocalizationManager.get_text("resume")
	if restart_button:
		restart_button.text = LocalizationManager.get_text("restart")
	if quit_button:
		quit_button.text = LocalizationManager.get_text("quit")

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
