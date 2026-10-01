#extends state
#
#var body:CharacterBody3D
#var dir:Vector3
#
#@export var wTimer:Timer
#@export var gCheck: RayCast3D
#
#
#func enter():
	#if get_parent().get_parent() is CharacterBody3D:
		#body = get_parent().get_parent()
	#else:
		#print("no body")
	#wTimer.start()
	#wTimer.timeout.connect(randomDir)
		#
#func update(delta:float):
	#if !gCheck.is_colliding():
		#randomDir()
		#body.move_and_slide()
	#body.dir = dir
#
#func randomDir():
	#dir = Vector3(randf_range(-1, 1), 0.0, randf_range(-1, 1))
	#wTimer.start()
extends state

@export var pause_min: float = 1.0
@export var pause_max: float = 2.5
@export var dist_min: float = 0.7
@export var dist_max: float = 1.5
@export var engage_dist: float = 2.5
@export var stop_dist: float = 0.12

var body: CharacterBody3D
var player: Node3D
var start_position: Vector3
var destination: Vector3
var pause_timer = 0.0
var is_moving: bool = false

func enter() -> void:
	body = get_parent().get_parent() as CharacterBody3D
	start_position = body.global_position
	player = get_tree().get_first_node_in_group("player") as Node3D
	pause_timer = randf_range(pause_min, pause_max)
	is_moving = false
	body.call("set_move_direction", Vector3.ZERO)


func physics_update(delta:float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	
	if is_instance_valid(player):
		if _flat_distance(body.global_position, player.global_position) <= engage_dist:
			body.call("set_move_direction", Vector3.ZERO)
			get_parent().change_state("attack")
			return
		
	if is_moving:
		var to_destination = destination - body.global_position
		to_destination.y = 0
		
		if to_destination.length() <= stop_dist:
			is_moving = false
			pause_timer = randf_range(pause_min, pause_max)
			body.call("set_move_direction", Vector3.ZERO)
		else:
			body.call("set_move_direction", to_destination.normalized())
	else:
		body.call("set_move_direction", Vector3.ZERO)
		pause_timer -= delta
		
		if pause_timer <= 0.0:
			_choose_destination()

func exit() -> void:
	if is_instance_valid(body):
		body.call("set_move_direction", Vector3.ZERO)

func _choose_destination():
	var angle = randf() * TAU
	var distance = randf_range(dist_min, dist_max)
	var offset = Vector2.RIGHT.rotated(angle) * distance
	
	destination = start_position + Vector3(offset.x, 0, offset.y)
	is_moving = true

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
	
