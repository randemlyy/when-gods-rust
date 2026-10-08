class_name MovementComponent
extends Node


@onready var body: CharacterBody3D = $".."
@export var speed:float = 2.0

var grounded:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta: float, movedir:Vector3, body:CharacterBody3D) -> void:
	grounded = body.is_on_floor()
	if grounded:
		body.velocity.x = speed * movedir.x
		body.velocity.z = speed * movedir.z
		body.velocity.y = -0.1
	else:
		body.velocity.y = body.get_gravity().y
	
	var look_dir: Vector3 = movedir
	look_dir.y = 0
	
	if look_dir.length_squared() > 0.05:
		var look_target = body.global_position + look_dir.normalized()
		body.look_at(look_target, Vector3.UP)
