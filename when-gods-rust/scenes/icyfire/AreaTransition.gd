extends Area3D

@export var PlayerSpawnPosition: Node3D
@onready var player: CharacterBody3D = self.get_tree().get_first_node_in_group("player")


func _on_body_entered(body: Node3D) -> void:
	if body == player:
		player.global_position = PlayerSpawnPosition.global_position
		pass
	pass # Replace with function body.
