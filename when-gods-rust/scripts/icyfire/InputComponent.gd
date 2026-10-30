class_name InputComponent
extends Node

var dir:Vector2
var dodge:bool
var block:bool
var block_held: bool
var attack:bool
var upgrade_menu: bool
var interact:bool
var InvBool:bool = false
var use:bool
var lock_on:bool
var inv_menu: bool

func update(delta: float) -> void:
	dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dodge = Input.is_action_just_pressed("dodge")
	block = Input.is_action_just_pressed("block")
	block_held = Input.is_action_pressed("block")
	attack = Input.is_action_just_pressed("attack")
	interact = Input.is_action_just_pressed("PickUp")
	upgrade_menu = Input.is_action_just_pressed("open_upgrade_menu")
	use = Input.is_action_just_pressed("use")
	lock_on = Input.is_action_just_pressed("lock_on")
	inv_menu = Input.is_action_just_pressed("inv_open")
