extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player fell")
		body.onDeath()
	else:
		body.queue_free()
