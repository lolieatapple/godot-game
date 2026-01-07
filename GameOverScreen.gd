extends CanvasLayer

@onready var title_label: Label = $Panel/CenterContainer/VBoxContainer/Title
@onready var score_label: Label = $Panel/CenterContainer/VBoxContainer/ScoreLabel
@onready var play_again_button: Button = $Panel/CenterContainer/VBoxContainer/PlayAgainButton
@onready var menu_button: Button = $Panel/CenterContainer/VBoxContainer/MenuButton

var final_score: int = 0

func _ready() -> void:
	hide()
	LocalizationManager.language_changed.connect(_update_text)
	_update_text()

func show_game_over(score: int):
	final_score = score
	_update_text()
	show()
	get_tree().paused = true

func _update_text():
	if title_label:
		title_label.text = LocalizationManager.get_text("game_over")
	if score_label:
		score_label.text = LocalizationManager.get_text("final_score") + str(final_score)
	if play_again_button:
		play_again_button.text = LocalizationManager.get_text("play_again")
	if menu_button:
		menu_button.text = LocalizationManager.get_text("menu")

func _on_play_again_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://StartScreen.tscn")
