class_name BlockComponent
extends Node

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var resolve_drain: float = 20.0
@export var early_parry_window: float = 0.15
@export var late_parry_window: float = 0.04
@export var resolve_on_parry: float = 40.0

var last_block_press_time: float = -1.0e20
var is_blocking: bool = false

func update(block_held: bool, block_pressed: bool, delta: float) -> void:
	if block_pressed:
		last_block_press_time = float(Time.get_ticks_usec()) / 1_000_000.0
		
	if not block_held or resolveC.cResolve <= 0.0:
		is_blocking = false
		return
	
	is_blocking = true
	var cost = minf(resolve_drain * delta, resolveC.cResolve)
	resolveC.useResolve(cost)
	
	if resolveC.cResolve <= 0.0:
		is_blocking = false

func check_parry_press(impact_time: float) -> bool:
	var parry_offset = last_block_press_time - impact_time
	
	if parry_offset < -early_parry_window:
		return false
	if parry_offset > late_parry_window:
		return false
	
	last_block_press_time = -1.0e20
	return true
