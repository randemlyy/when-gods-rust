extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var attackC: AttackComponent = $AttackComponent
@onready var cameraC: CameraComponent = $CameraComponent

@export var mouse_sens:float = 0.002

func _ready() -> void:
	cameraC.start()

func _process(delta: float) -> void:
	inputC.update(delta)
	cameraC.update(self)

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	# actual movement direction, taking into account everything
	attackC.physics_update(delta, inputC.attack)
	if not attackC.is_attacking:
		movementC.physics_update(delta, Vector3(inputC.dir.x, 0, inputC.dir.y), self)
	move_and_slide()
