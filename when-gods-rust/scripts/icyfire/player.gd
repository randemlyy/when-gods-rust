extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var cameraC: CameraComponent = $CameraComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var resolveC: ResolveComponent = $ResolveComponent
@onready var inventoryC: InventoryComponent = $InventoryComponent
@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var mouse_sens:float = 0.002
@export var stagger_dura: float = 0.8

var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	resolveC.start()

func _process(delta: float) -> void:
	inventoryC.isEquip = inputC.interact
	inventoryC.isAttack = inputC.attack
	inputC.update(delta)
	cameraC.update(self)
	resolveC.update(delta)
	inventoryC.update(delta, canCombo, canCrit, canStagger, resolveC)

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if staggerC.is_staggered:
		velocity.x = 0
		velocity.z = 0 
		return
		
	movementC.physics_update(delta, Vector3(inputC.dir.x, 0, inputC.dir.y), self)
	move_and_slide()

func take_hit(damage: int, hit_stagger_duration: float = 0.8) -> void:
	healthC.take_damage(damage)
