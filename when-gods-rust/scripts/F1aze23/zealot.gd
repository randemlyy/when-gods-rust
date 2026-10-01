extends CharacterBody3D
 
@onready var sMachine: StateMachine = $StateMachine
@onready var moveC: MovementComponent = $MovementComponent
@onready var gCheck: RayCast3D = $GroundCheck
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent

var dir:Vector3

func set_move_direction(new_dir: Vector3) -> void:
	dir = new_dir

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if staggerC.is_staggered:
		dir = Vector3.ZERO
		velocity.x = 0.0
		velocity.y = 0.0
		move_and_slide()
		return
	# actual movement direction, taking into account everything
	moveC.physics_update(delta, dir, self)
	move_and_slide()

func take_hit(damage: int, hit_stagger_duration: float = 0.65) -> void:
	healthC.take_damage(damage)
	
	var current_state = sMachine.cState
	if current_state != null and current_state.has_method("is_winding_up") and current_state.call("is_winding_up"):
		sMachine.change_state("wander")
		staggerC.apply_stagger(hit_stagger_duration)
