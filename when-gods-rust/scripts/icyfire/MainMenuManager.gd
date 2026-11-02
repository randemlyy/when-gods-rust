extends Node

const TEST_LEVEL := preload("uid://bj4s2hn8pbd5d")
@onready var music_manager: Node = $"../../MusicManager"
@onready var button: Button = $Button
@onready var button_2: Button = $Button2

func _ready() -> void:
	music_manager.play_menu_music()

func _on_button_button_down() -> void:
	music_manager.play_gameplay_music()
	print("lvl change")
	get_tree().change_scene_to_packed(TEST_LEVEL)

func _on_button_2_button_down() -> void:
	print("quit")
	get_tree().quit()
