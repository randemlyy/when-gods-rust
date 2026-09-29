class_name InputComponent
extends Node

var dir:Vector2
var attack: bool
var dodge: bool
var block: bool

func _process(delta: float) -> void:
	dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	attack = Input.is_action_just_pressed("attack")
	block = Input.is_action_just_pressed("block")
	dodge = Input.is_action_pressed("block")
