extends CharacterBody3D
 
@onready var sMachine: StateMachine = $StateMachine
@onready var moveC: MovementComponent = $MovementComponent
@onready var gCheck: RayCast3D = $GroundCheck
var dir:Vector3

func set_move_direction(new_dir: Vector3) -> void:
	dir = new_dir

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	# actual movement direction, taking into account everything
	moveC.physics_update(delta, dir, self)
	move_and_slide()
