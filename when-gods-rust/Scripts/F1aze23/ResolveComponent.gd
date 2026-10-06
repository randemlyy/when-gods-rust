class_name ResolveComponent
extends Node

@export var maxResolve:float = 100.0
@export var cResolve:float = 100.0
@export var resolveBar:ProgressBar
@export var resolveDecay:float = 0.05
var canDecay:bool = true
@onready var progress_bar: ProgressBar = $"../CanvasLayer/Control/ResolveBar"

func start():
	resolveBar.max_value = maxResolve
	resolveBar.value = cResolve

func update(delta:float):
	resolveBar.value = cResolve
	if cResolve >= maxResolve:
		cResolve = maxResolve
	elif cResolve <= 0.0:
		cResolve = 0

	if canDecay:
		cResolve-=resolveDecay
	
	progress_bar.value = (cResolve/maxResolve) * 100

func gainResolve(amt:float):
	cResolve += amt
	canDecay = false
	var timer = Timer.new()
	timer.wait_time = 2
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func():
		canDecay = true
		)
	timer.start()
	print(amt, " Resolve Gained")

func useResolve(amt:float):
	cResolve -= amt
	print(amt, " Resolve Lost")
