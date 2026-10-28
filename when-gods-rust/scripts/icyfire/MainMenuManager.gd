extends Node

const TEST_LEVEL := preload("res://scenes/randemlyy/THEtestlevel.tscn")

func _ready() -> void:
	MusicManager.play_menu_music()

func _on_button_button_down() -> void:
	MusicManager.play_gameplay_music()
	get_tree().change_scene_to_packed(TEST_LEVEL)

func _on_button_2_button_down() -> void:
	get_tree().quit()
