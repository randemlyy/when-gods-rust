extends state

@export var windup_time: float = 0.55
@export var recovery_time: float = 0.8
@export var attack_range: float = 1.8

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
		body.call("start_attack")
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

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
	
func is_winding_up() -> bool:
	return phase == Phase.WINDUP
