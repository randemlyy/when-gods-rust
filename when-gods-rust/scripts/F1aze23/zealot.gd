extends CharacterBody3D
 
@onready var sMachine: StateMachine = $StateMachine
@onready var moveC: MovementComponent = $MovementComponent
@onready var gCheck: RayCast3D = $GroundCheck
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var hand: Node3D = $Hand
@onready var attack_anim: AnimationPlayer = $TestAnimPlayer
@onready var weapon: Weapon = $Hand/TestWeapon

var dir:Vector3

func _ready() -> void:
	healthC.died.connect(_on_died)
	
	
func _on_died() -> void:
	queue_free()

func set_move_direction(new_dir: Vector3) -> void:
	dir = new_dir

func start_attack() -> void:
	if is_instance_valid(weapon):
		weapon.startAttack(attack_anim)

func is_attacking() -> bool:
	return is_instance_valid(weapon) and weapon.isAttacking

func cancel_attack() -> void:
	if is_instance_valid(weapon):
		weapon.cancel_attack()
		
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if healthC.current_health <= 0:
		queue_free()
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if staggerC.is_staggered:
		dir = Vector3.ZERO
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	# actual movement direction, taking into account everything
	if !staggerC.is_staggered:
		moveC.physics_update(delta, dir, self)
	else:
		velocity.move_toward(Vector3.ZERO, 1)
	move_and_slide()

func take_hit(damage: int, hit_stagger_duration: float = 0.65, hit_direction = Vector3.RIGHT) -> void:
	healthC.take_damage(damage)
	var current_state = sMachine.cState
	var was_winding_up = (current_state != null and current_state.has_method("is_winding_up") and current_state.call("is_winding_up"))
	staggerC.apply_stagger(hit_stagger_duration)
	cancel_attack()
	
	if current_state != null and current_state.has_method("is_winding_up"):
		sMachine.change_state("wander")
	
	if was_winding_up:
		staggerC.apply_stagger(hit_stagger_duration + 0.35)
