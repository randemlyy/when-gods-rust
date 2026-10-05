extends Node

func _on_button_button_down() -> void:
	print("change scenme")
	get_tree().change_scene_to_packed(preload("uid://1vu1ugm3m8u6"))


func _on_button_2_button_down() -> void:
	get_tree().quit()
