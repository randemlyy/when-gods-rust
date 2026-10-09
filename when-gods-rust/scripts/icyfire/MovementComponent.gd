class_name MovementComponent
extends Node


@onready var body: CharacterBody3D = $".."
@export var accel: float
@export var deccel: float
@export var speed:float

var grounded:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta: float, movedir:Vector3, body:CharacterBody3D) -> void:
	grounded = body.is_on_floor()
	if grounded:
		var target_velocity = movedir * speed
		var horizontal_velocity = Vector2(body.velocity.x, body.velocity.z)
		
		var rate = accel
		if movedir.length_squared() < 0.001:
			rate = deccel
		horizontal_velocity = horizontal_velocity.move_toward(
			Vector2(target_velocity.x, target_velocity.z),
			rate * delta
		)
		body.velocity.x = horizontal_velocity.x
		body.velocity.z = horizontal_velocity.y
		body.velocity.y = -0.1
	else:
		body.velocity.y = body.get_gravity().y
	
	var look_dir: Vector3 = movedir
	look_dir.y = 0
	
	if look_dir.length_squared() > 0.05:
		var target_yaw = atan2(-look_dir.x, -look_dir.z)
		body.rotation.y = rotate_toward(
			body.rotation.y,
			target_yaw,
			20.0 * delta
		)
