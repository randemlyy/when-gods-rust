class_name AttackState
extends state

@export var attack_range: float = 1.8
@export var windup_time: float = 0.55
@export var recovery_time: float = 0.8
@export var range_mult: float = 1.2

enum Phase {
	WINDUP,
	RECOVERY
}

var body: CharacterBody3D
var target: Node3D
var phase: Phase
var timer: float = 0.0

func enter() -> void:
	body = sm.get_parent() as CharacterBody3D
	target = _find_target()
	phase = Phase.WINDUP
	timer = windup_time
	_stop_moving()
	
func physics_update(delta:float) -> void:
	if not is_instance_valid(target):
		target = _find_target()
		if not is_instance_valid(target):
			sm.change_state("wander")
			return
	_face_target()
	timer -= delta
	
	if phase == Phase.WINDUP and timer <= 0:
		perform_attack(target)
		phase = Phase.RECOVERY
		timer = recovery_time
		
	elif phase == Phase.RECOVERY and timer <= 0:
		if _flat_distance(body.global_position, target.global_position) <= attack_range * range_mult:
			phase = Phase.WINDUP
			timer = windup_time
		else:
			get_parent().change_state("wander")

func exit() -> void:
	_stop_moving()

func perform_attack(_attack_target: Node3D) -> void:
	pass

func _is_winding_up() -> bool:
	return phase == Phase.WINDUP

func target_in_range(attack_target: Node3D):
	return _flat_distance(body.global_position, attack_target.global_position) <= attack_range

func target_in_front(attack_target: Node3D, minimum_dot: float) -> bool:
	var direction = _flat_direction_to(attack_target)
	if direction ==  Vector3.ZERO:
		return true
	
	var forward = -body.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	return forward.dot(direction) >= minimum_dot

func dir_to_target(attack_target: Node3D) -> Vector3:
	return _flat_direction_to(attack_target)

func _find_target() -> Node3D:
	return get_tree().get_first_node_in_group("player") as Node3D

func _face_target() -> void:
	var direction = _flat_direction_to(target)
	if direction != Vector3.ZERO:
		body.look_at(body.global_position + direction, Vector3.UP)

func _flat_direction_to(attack_target: Node3D) -> Vector3:
	var direction := attack_target.global_position - body.global_position
	direction.y = 0.0
	return direction.normalized()

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
	
func _stop_moving() -> void:
	if is_instance_valid(body) and body.has_method("set_move_direction"):
		body.call("set_move_direction", Vector3.ZERO)
