class_name InputComponent
extends Node


var dir:Vector2
#var jump:bool
var dodge:bool
var block:bool
var attack:bool
#var attack2:bool
var interact:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dodge = Input.is_action_just_pressed("dodge")
	block = Input.is_action_just_pressed("block")
	attack = Input.is_action_just_pressed("attack")
