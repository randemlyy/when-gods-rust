class_name EnemyStates
extends state

enum Phase {
	IDLE,
	WINDUP,
	ACTIVE,
	RECOVERY
}

@export_group("Wiring")
@export var body: CharacterBody3D
@export var nav: NavigationAgent3D
@export var movementC: MovementComponent
@export var model: Node3D
@export var front_hitbox: Area3D
@export var wide_hitbox: Area3D
@export var shockwave: Area3D

@export_group("Movement")
@export var move_speed: float = 3.2
@export var turn_speed: float = 2.0
@export var stop_distance: float = 2.2
@export var decision_time: float = 0.9

var player: Node3D
var phase: Phase = Phase.IDLE
var phase_left: float = 0.0
var current: Dictionary = {}
var move_dir = Vector3.ZERO

var _attack_serial = 0
var _attack_id = ""
var _hit_flags: Array[bool] = []
var _active_elapsed = 0.0
var _last_attack_id = ""
var _model_base = Vector3.ZERO
var _telegraph: Node3D
var _tween: Tween

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player") as Node3D
	if is_instance_valid(nav) and is_instance_valid(body):
		nav.set_navigation_map(body.get_world_3d().navigation_map)
	if is_instance_valid(movementC):
		movementC.speed = move_speed
	if is_instance_valid(model):
		_model_base = model.position
	
	phase = Phase.IDLE
	phase_left = decision_time
	current = {}
	move_dir = Vector3.ZERO
	_hit_flags.clear()
	_kill_telegraph()
	_kill_tween()
	if is_instance_valid(body) and is_instance_valid(player):
		_face_instant()

func _kill_telegraph() -> void:
	pass

func _kill_tween() -> void:
	pass

func _face_instant() -> void:
	pass

