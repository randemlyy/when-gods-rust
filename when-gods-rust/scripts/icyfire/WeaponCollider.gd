extends Area3D

@onready var test_weapon: Weapon = $".."


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		body.get_node_or_null("HealthComponent").take_damage(test_weapon.rawDamage)
	pass # Replace with function body.
