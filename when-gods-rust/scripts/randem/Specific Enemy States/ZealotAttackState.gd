class_name ZealotAttackState
extends AttackState

@export var damage = 10
@export_range(-1.0, 1.0, 0.05) var facing_min: float = 0.55
@export var stagger_duration: float = 0.8

func perform_attack(attack_target: Node3D) -> void:
	if not is_instance_valid(attack_target):
		return
	if not attack_target.has_method("take_hit"):
		return
	if not target_in_range(attack_target):
		return
	if not target_in_front(attack_target, facing_min):
		return
	
	attack_target.call(
		"take_hit",
		damage,
		stagger_duration,
		dir_to_target(attack_target)
	)
