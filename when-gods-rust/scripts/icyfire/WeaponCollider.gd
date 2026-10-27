class_name WeaponCollider
extends Area3D

signal hit_landed(target: Node3D)

@onready var test_weapon: Weapon = $".."

var hit_enemies_this_swing: Array[Node3D] = []

func begin_swing() -> void:
	hit_enemies_this_swing.clear()

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Enemy"):
		return
	if body in hit_enemies_this_swing:
		return

	var health = body.get_node_or_null("HealthComponent") as HealthComponent
	if not health or health.current_health <= 0:
		return
	
	var stagger = body.get_node_or_null("StaggerComponent") as StaggerComponent

	var is_target_staggered = (stagger != null) and (stagger.is_staggered)
	var damage = test_weapon.get_attack_damage(is_target_staggered)

	hit_enemies_this_swing.append(body)
	health.take_damage(damage)
	hit_landed.emit(body)

	if stagger and health.current_health > 0:
		stagger.apply_stagger(test_weapon.hit_stagger_duration)
