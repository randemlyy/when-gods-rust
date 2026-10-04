class_name AttackComponent
extends Node

enum State {
	IDLE,
	ATTACKING,
	COMBO_WINDOW,
	RECOVERY
}

signal attack_started

@onready var body: CharacterBody3D = $".."
#@onready var facing: Vector3

@export var attack_durations: Array[float] = [0.55, 0.65, 0.8]
@export var combo_window_starts: Array[float] = [0.25, 0.3, 0.0]
@export var combo_window_ends: Array[float] = [0.5, 0.55, 0.0]
@export var crit_window_starts: Array[float] = [0.34, 0.4, 0]
@export var crit_window_ends: Array[float] = [0.42, 0.48, 0]
@export var lunge_distances: Array[float] = [1.0, 1.2, 1.5]

var state = State.IDLE
var current_attack: int = 0
var attack_time: float = 0.0
var combo_queued: bool = false
var attack_forgiveness: float = 0.15
var recovery_time: float = 0.0
var is_current_crit: bool = false
var is_queued_crit: bool = false

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
		State.RECOVERY:
			_update_recovery(delta, attack_pressed)

func _update_attack(delta: float) -> void:
	attack_time += delta
	
	if attack_time >= combo_window_starts[current_attack]:
		state = State.COMBO_WINDOW
	if attack_time >= attack_durations[current_attack] and not recovery_time >= attack_forgiveness:
		state = State.RECOVERY

func _update_combo_window(delta: float, attack_pressed: bool) -> void:
	attack_time += delta
	
	if attack_pressed and current_attack < attack_durations.size() - 1 and attack_time <= combo_window_ends[current_attack]:
		if attack_time >= crit_window_starts[current_attack] and attack_time <= crit_window_ends[current_attack]:
			is_queued_crit = true
		combo_queued = true
	if attack_time >= attack_durations[current_attack] and not recovery_time >= attack_forgiveness:
		state = State.RECOVERY

func _finish_current_attack() -> void:
	if combo_queued and current_attack < attack_durations.size() - 1:
		_start_attack(current_attack + 1, is_queued_crit)
	else:
		_end_combo()
func _start_attack(index: int, attack_is_crit: bool = false) -> void:
	current_attack = index
	is_current_crit = attack_is_crit
	print("attack ", index + 1, " crit: ", is_current_crit)
	is_queued_crit = false
	attack_time = 0.0
	recovery_time = 0.0
	combo_queued = false
	state = State.ATTACKING
	attack_started.emit()
	
	var forward := -body.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var lunge_speed := lunge_distances[index] / attack_durations[index]
	body.velocity.x = forward.x * lunge_speed
	body.velocity.z = forward.z * lunge_speed

func _update_recovery(delta: float, attack_pressed: bool) -> void:
	recovery_time += delta

	if attack_pressed and current_attack < attack_durations.size() - 1:
		_start_attack(current_attack + 1, is_queued_crit)
		return

	if recovery_time >= attack_forgiveness:
		_finish_current_attack()


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
