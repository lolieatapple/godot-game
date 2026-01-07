extends Control

func _ready():
	$VBoxContainer/BtnZH.grab_focus()

func _on_btn_zh_pressed():
	LocalizationManager.set_language("zh_CN")
	go_to_start_screen()

func _on_btn_en_pressed():
	LocalizationManager.set_language("en")
	go_to_start_screen()

func go_to_start_screen():
	get_tree().change_scene_to_file("res://StartScreen.tscn")
