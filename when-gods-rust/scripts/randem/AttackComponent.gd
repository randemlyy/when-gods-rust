class_name AttackComponent
extends Node

enum State {
	IDLE,
	ATTACKING,
	COMBO_WINDOW
}

@onready var body: CharacterBody3D = $".."
#@onready var facing: Vector3

@export var attack_durations: Array[float] = [0.55, 0.65, 0.8]
@export var combo_window_starts: Array[float] = [0.25, 0.3, 0.0]
@export var combo_window_ends: Array[float] = [0.5, 0.55, 0.0]
@export var lunge_distances: Array[float] = [1.0, 1.2, 1.5]

var state = State.IDLE
var current_attack: int = 0
var attack_time: float = 0.0
var combo_queued: bool = false

var is_winding_up: bool:
	get:
		return state == State.ATTACKING and attack_time < combo_window_starts[current_attack]

var is_attacking: bool: 
	get: return state != State.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta: float, attack_pressed: bool) -> void:
	
	match state:
		State.IDLE:
			if attack_pressed:
				_start_attack(0)
		State.ATTACKING:
			_update_attack(delta)
		State.COMBO_WINDOW:
			_update_combo_window(delta, attack_pressed)

func _update_attack(delta: float) -> void:
	attack_time += delta
	
	if attack_time >= combo_window_starts[current_attack]:
		state = State.COMBO_WINDOW
	if attack_time >= attack_durations[current_attack]:
		_finish_current_attack()

func _update_combo_window(delta: float, attack_pressed: bool) -> void:
	attack_time += delta
	
	if attack_pressed and current_attack < attack_durations.size() - 1 and attack_time <= combo_window_ends[current_attack]:
		combo_queued = true
	if attack_time >= attack_durations[current_attack]:
		_finish_current_attack()

func _finish_current_attack() -> void:
	if combo_queued and current_attack < attack_durations.size() - 1:
		_start_attack(current_attack + 1)
	else:
		_end_combo()

func _start_attack(index: int) -> void:
	current_attack = index
	attack_time = 0.0
	combo_queued = false
	state = State.ATTACKING
	
	var forward := -body.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var lunge_speed := lunge_distances[index] / attack_durations[index]
	body.velocity.x = forward.x * lunge_speed
	body.velocity.z = forward.z * lunge_speed
	
	print("attacking")

func _end_combo() -> void:
	print("attack combo finished")
	state = State.IDLE
	body.velocity.x = 0.0
	body.velocity.z = 0.0
	
func cancel_attack() -> void:
	state = State.IDLE
	attack_time = 0.0
	combo_queued = false
	body.velocity.x = 0.0
	
