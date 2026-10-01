class_name StaggerComponent
extends Node

signal stagger_started
signal stagger_ended
var time_left: float = 0.0

var is_staggered: bool:
	get:
		return time_left > 0.0

func apply_stagger(duration: float) -> void:
	if duration <= 0.0:
		return
	
	var was_staggered := is_staggered
	time_left = max(time_left, duration)
	
	if not was_staggered:
		stagger_started.emit()

func _physics_process(delta: float) -> void:
	if not is_staggered:
		return
	
	time_left = max(time_left - delta, 0.0)
	
	if time_left == 0:
		stagger_ended.emit()
