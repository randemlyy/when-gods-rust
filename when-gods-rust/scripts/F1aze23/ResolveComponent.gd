class_name ResolveComponent
extends Node

signal resolve_changed(current: float, maximum: float)

@onready var loadPenaltyC: LoadPenaltyComponent = $"../LoadPenaltyComponent"
@onready var player: CharacterBody3D = get_parent().get_parent() as CharacterBody3D

@export var offset := Vector3(0, 1.8, 0)
@export var maxResolve:float = 100.0
@export var cResolve:float = 100.0
@export var resolveDecay:float = 0.03

var canDecay:bool = true 

func _ready() -> void:
	maxResolve = maxf(maxResolve, 0.0)
	cResolve = clampf(cResolve, 0.0, maxResolve)
	resolve_changed.emit(cResolve, maxResolve)

	
func update(delta:float):
	if canDecay:
		cResolve -= resolveDecay * loadPenaltyC.resolve_drain_mult() * 0.8 * delta
	
	cResolve = clampf(cResolve, 0.0, maxResolve)
	resolve_changed.emit(cResolve, maxResolve)
	
func gainResolve(amt:float):
	cResolve = clampf(cResolve + amt, 0.0, maxResolve)
	resolve_changed.emit(cResolve, maxResolve)

	canDecay = false
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func() -> void:
		canDecay = true
	)
	
func useResolve(amt:float):
	amt *= loadPenaltyC.resolve_drain_mult()
	cResolve = maxf(cResolve - amt, 0.0)
	resolve_changed.emit(cResolve, maxResolve)
