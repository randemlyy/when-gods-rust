extends Area3D
const FINISHSCREEN = preload("uid://b13krcvbxuyu0")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLayer"):
		get_tree().change_scene_to_packed(FINISHSCREEN)
