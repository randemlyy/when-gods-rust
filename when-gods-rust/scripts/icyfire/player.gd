extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var cameraC: CameraComponent = $CameraComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var resolveC: ResolveComponent = $ResolveComponent
@onready var inventoryC: InventoryComponent = $InventoryComponent
@onready var blockC: BlockComponent = $BlockComponent
@onready var anim: AnimationPlayer = $TestAnimPlayer
@onready var health_bar: ProgressBar = $CanvasLayer/Control/HealthBar
@onready var iArea: Area3D = $InteractArea

@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var mouse_sens:float = 0.002
@export var stagger_dura: float = 0.8

var TimeSinceDmg:float = 0
var DmgTime:float = 1
var block_animation_started := false
var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	resolveC.start()
	healthC.died.connect(onDeath)
	blockC.blocking_started.connect(_on_blocking_started)
	blockC.blocking_ended.connect(_on_blocking_ended)

func _process(delta: float) -> void:
	inputC.update(delta)
	blockC.update(inputC.block_held and not _weapon_is_attacking() and not staggerC.is_staggered, inputC.block, delta)
	inventoryC.isEquip = inputC.interact
	inventoryC.isAttack = inputC.attack
	inventoryC.update(resolveC, anim, canStagger, canCombo, canCrit)
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
	move_and_slide()


func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction:Vector3 = Vector3.LEFT) -> void:
	var impact_time = float(Time.get_ticks_usec()) / 1_000_000.0
	var was_blocking_at_impact = blockC.is_blocking
	
	await get_tree().create_timer(blockC.late_parry_window).timeout
	await get_tree().process_frame
	
	if not is_inside_tree():
		return
		
	if blockC.check_parry_press(impact_time):
		resolveC.gainResolve(blockC.resolve_on_parry)
		print("parried")
		return
		
	if was_blocking_at_impact:
		print("blocked")
		return
	healthC.take_damage(damage)
	staggerC.apply_stagger(hit_stagger_duration)
	print(hit_direction)
	velocity = hit_direction

func _on_blocking_started() -> void:
	anim.play("Block")

func _on_blocking_ended() -> void:
	if anim.current_animation == "Block":
		anim.play("Unblock")

func _weapon_is_attacking() -> bool:
	return is_instance_valid(inventoryC.cWeapon) and inventoryC.cWeapon.isAttacking

func onDeath():
	queue_free()
	print("Wow ma so bad you are")
	print("changed")
	get_tree().change_scene_to_packed(load("uid://o73v2cty65b6"))
