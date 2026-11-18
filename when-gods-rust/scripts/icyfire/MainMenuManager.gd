extends Node

const TEST_LEVEL := preload("uid://bj4s2hn8pbd5d")
const BOSS_ARENA := preload("uid://7eucy55jil3v")

@onready var button: Button = $Button
@onready var button_2: Button = $Button2
@onready var button_3: Button = $Button3

func _ready() -> void:
	MusicManager.play_menu_music()

func _on_button_button_down() -> void:
	MusicManager.play_gameplay_music()
	print("lvl change")
	get_tree().change_scene_to_packed(TEST_LEVEL)

func _on_button_2_button_down() -> void:
	print("quit")
	get_tree().quit()

func _on_button_3_button_down() -> void:
	MusicManager.play_gameplay_music()
	get_tree().change_scene_to_packed(BOSS_ARENA)