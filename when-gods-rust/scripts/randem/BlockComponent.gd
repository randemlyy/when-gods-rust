class_name BlockComponent
extends Node

signal blocking_started
signal blocking_ended

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var block_resolve_cost: float = 10.0
@export var early_parry_window: float = 0.15
@export var late_parry_window: float = 0.04
@export var resolve_on_parry: float = 40.0

var last_block_press_time: float = -1.0e20
var is_blocking: bool = false

func update(block_held: bool, block_pressed: bool, delta: float) -> void:
	if block_pressed:
		last_block_press_time = float(Time.get_ticks_usec()) / 1_000_000.0
		
	if not block_held or resolveC.cResolve <= 0.0:
		_set_blocking(false)
		return
	
	_set_blocking(true)
	if resolveC.cResolve <= 0.0:
		_set_blocking(false)

func spend_for_block() -> bool:
	if resolveC.cResolve < block_resolve_cost:
		_set_blocking(false)
		return false
	
	resolveC.useResolve(block_resolve_cost)
	
	if resolveC.cResolve <= 0.0:
		_set_blocking(false)
	
	return true 

func _set_blocking(value: bool) -> void:
	if is_blocking == value:
		return
	
	is_blocking = value
	
	if is_blocking:
		blocking_started.emit()
	else:
		blocking_ended.emit()	

func check_parry_press(impact_time: float) -> bool:
	var parry_offset = last_block_press_time - impact_time
	
	if parry_offset < -early_parry_window:
		return false
	if parry_offset > late_parry_window:
		return false
	
	last_block_press_time = -1.0e20
	return true
