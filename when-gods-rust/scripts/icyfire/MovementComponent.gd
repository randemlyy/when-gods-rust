class_name MovementComponent
extends Node


@onready var body: CharacterBody3D = $".."


@export var acceleration:float = 1500.0
@export var braking:float = 1800.0
@export var speed:float = 5.0

var grounded:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta: float, movedir:Vector3, body:CharacterBody3D) -> void:
	grounded = body.is_on_floor()
	if grounded:
		body.velocity.x = speed * movedir.x
		body.velocity.z = speed * movedir.z
	if movedir.length() > 0:
		var look_target = body.global_transform.origin + movedir
		body.look_at(look_target, Vector3.UP)
