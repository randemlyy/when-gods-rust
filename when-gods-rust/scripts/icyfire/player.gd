extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var cameraC: CameraComponent = $CameraComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var resolveC: ResolveComponent = $ResolveComponent
@onready var inventoryC: InventoryComponent = $InventoryComponent
@onready var attackC: AttackComponent = $AttackComponent

@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var mouse_sens:float = 0.002
@export var stagger_dura: float = 0.8
@onready var health_bar: ProgressBar = $CanvasLayer/Control/HealthBar
@onready var iArea: Area3D = $InteractArea

var TimeSinceDmg:float = 0
var DmgTime:float = 1
@onready var attackArea: Area3D = $AttackArea


var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	resolveC.start()
	attackC.attack_started.connect(_on_attack_started)
	inventoryC.anim.animation_finished.connect(attackC.check_animation_finished)
	healthC.died.connect(onDeath)

func _process(delta: float) -> void:
	inventoryC.isEquip = inputC.interact
	inventoryC.update()
	inputC.update(delta)
	cameraC.update(self)
	resolveC.update(delta)
	health_bar.value = healthC.current_health
#func _unhandled_input(event:InputEvent) -> void:
	#if event is InputEventMouseButton:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif event.is_action_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	TimeSinceDmg += delta
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if staggerC.is_staggered:
		velocity.x = 0
		velocity.z = 0 
		return
		
	if !staggerC.is_staggered:
#		print ("not staggered")
		movementC.physics_update(delta, Vector3(inputC.dir.x, 0, inputC.dir.y), self)
	else:
		print("staggered")
	attackC.physics_update(delta, inputC.attack)
	move_and_slide()


func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction:Vector3 = Vector3.LEFT) -> void:
	healthC.take_damage(damage)
	staggerC.apply_stagger(hit_stagger_duration)
	if attackC and attackC.is_winding_up:
		attackC.state = AttackComponent.State.IDLE
		staggerC.apply_stagger(hit_stagger_duration+0.3)
	
	print(hit_direction)
	velocity = hit_direction

func _on_attack_started(attack_index: int, is_crit: bool) -> void:
	if is_crit:
		resolveC.gainResolve(10)
	inventoryC.play_attack(attack_index, is_crit)

func onDeath():
	queue_free()
	print("Wow ma so bad you are")
	print("changed")
	get_tree().change_scene_to_packed(load("uid://o73v2cty65b6"))
