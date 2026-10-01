extends state

@export var attack_range: float = 1.8
@export var damage: int = 10
@export var windup_time: float = 0.55
@export var recovery_time: float = 0.8
@export var facing_min: float = 0.55

enum Phase {
	WINDUP,
	RECOVERY
}

var body: CharacterBody3D
var player: Node3D
var phase: Phase
var timer: float

func enter() -> void:
	body = sm.get_parent() as CharacterBody3D
	player = get_tree().get_first_node_in_group("player") as Node3D
	phase = Phase.WINDUP
	timer = windup_time
	body.call("set_move_direction", Vector3.ZERO)

func physics_update(delta:float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
		get_parent().change_state("wander")
		return
	_face_player()
	timer -= delta
	
	if phase == Phase.WINDUP and timer <= 0:
		_try_hit()
		phase = Phase.RECOVERY
		timer = recovery_time
	elif phase == Phase.RECOVERY and timer <= 0:
		if _flat_distance(body.global_position, player.global_position) <= attack_range * 1.2:
			phase = Phase.WINDUP
			timer = windup_time
		else:
			get_parent().change_state("wander")

func exit() -> void:
	if is_instance_valid(body):
		body.call("set_move_direction", Vector3.ZERO)

func _face_player() -> void:
	var target = player.global_position
	target.y = body.global_position.y
	body.look_at(target, Vector3.UP)

func _try_hit() -> void:
	var to_player := player.global_position - body.global_position
	to_player.y = 0
	
	if to_player.length() > attack_range:
		return
	
	var forward = -body.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	if forward.dot(to_player.normalized()) < facing_min:
		return
	
	if player.has_method("take_damage"):
		player.call("take_damage", damage)
	print('hits')

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
