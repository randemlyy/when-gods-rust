extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent

@onready var eyes: Node3D = $eyes
@onready var idk: Node3D = $eyes/Node3D
@onready var camera_3d: Camera3D = $eyes/Node3D/Camera3D

@export var mouse_sens:float = 0.002

@onready var Input_dir = inputC.dir

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			eyes.rotate_y(-event.relative.x * mouse_sens)
			idk.rotate_x(-event.relative.y * mouse_sens)
			idk.rotation.x = clamp(idk.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	velocity.y += get_gravity().y * delta
	# actual movement direction, taking into account everything.
	
	inputC.process(delta)
	var direction := (eyes.transform.basis * Vector3(Input_dir.x, 0, Input_dir.y)).normalized()
	print (Input_dir)
	print (direction)
	movementC.physics_process(delta, direction)
	
	pass
