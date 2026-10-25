class_name LockOnComponent
extends Node

signal target_changed(target: Node3D)

@export var lock_on_range: float = 12.0

@onready var body: CharacterBody3D = get_parent().get_parent() as CharacterBody3D

var target: Node3D = null

func toggle_target() -> void:
	if is_instance_valid(target):
		_set_target(null)
	else:
		_set_target(_find_target())

func update() -> void:
	if target == null:
		return
	
	if not is_instance_valid(target):
		_set_target(null)
		return
	
	if body.global_position.distance_to(target.global_position) > lock_on_range:
		_set_target(null)

func clear_target() -> void:
	_set_target(null)

func _set_target(new_target: Node3D) -> void:
	if target == new_target:
		return
	
	target = new_target
	target_changed.emit(target)

func _find_target() -> Node3D:
	var closest: Node3D = null
	var closest_distance = lock_on_range

	for node in get_tree().get_nodes_in_group("Enemy"):
		if not node is Node3D:
			continue
		
		var candidate = node as Node3D
		var distance = body.global_position.distance_to(candidate.global_position)

		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	
	return closest
