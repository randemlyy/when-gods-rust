extends CharacterBody3D


signal parry_succeeded(target: Node3D, target_staggered: StaggerComponent)

@onready var inputC: InputComponent = $Components/InputComponent
@onready var movementC: MovementComponent = $Components/MovementComponent
@onready var cameraC: CameraComponent = $Components/CameraComponent
@onready var healthC: HealthComponent = $Components/HealthComponent
@onready var staggerC: StaggerComponent = $Components/StaggerComponent
@onready var resolveC: ResolveComponent = $Components/ResolveComponent
@onready var inventoryC: InventoryComponent = $Components/InventoryComponent
@onready var blockC: BlockComponent = $Components/BlockComponent
@onready var animC: AnimationComponent = $Components/AnimationComponent
@onready var anim: AnimationPlayer = $TestAnimPlayer
@onready var iArea: Area3D = $InteractArea
@onready var loadPenaltyC: LoadPenaltyComponent = $Components/LoadPenaltyComponent
@onready var dodgeC: DodgeComponent = $Components/DodgeComponent
@onready var upgradeC: UpgradeComponent = $Components/UpgradeComponent
@onready var interactC: InteractComponent = $Components/InteractComponent
@onready var riposteC: RiposteComponent = $Components/RiposteComponent
@onready var label_4: Label = $CanvasLayer/Control/Label4
@onready var lockOnC: LockOnComponent = $Components/LockOnComponent
@onready var uiC: PlayerUIController = $Components/PlayerUIController
@onready var hitReponse: PlayerHitResponse = $Components/PlayerHitResponse
@onready var attackC: AttackComponent = $Components/AttackComponent


@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var stagger_dura: float = 0.7
@export var invertControlsX:float = 1
@export var invertControlsY:float = 1
@export var SwitchControlAxes:bool = false
@export var max_heals = 4
@export var dodge_graze_resolve: float = 15
@export var heal_amount: int = 25

var TimeSinceDmg:float = 0
var DmgTime:float = 1
var block_animation_started := false
var	bodies_hit_this_swing: Array[Node3D] = []
var grazed_attacks: Dictionary = {}

func _ready() -> void:
	cameraC.start()
	healthC.start()
	healthC.died.connect(onDeath)
	blockC.blocking_started.connect(_on_blocking_started)
	blockC.blocking_ended.connect(_on_blocking_ended)
	hitReponse.parry_succeeded.connect(_on_hit_response_parry_succeeded)
	parry_succeeded.connect(riposteC.on_parry)
	riposteC.feedback_requested.connect(_on_riposte_feedback_requested)
	lockOnC.target_changed.connect(cameraC.set_lock_on_target)
	uiC.refill_heals_requested.connect(_on_refill_heals_pressed)
	staggerC.stagger_started.connect(_on_stagger_started)
	
func _process(delta: float) -> void:
	inputC.update(delta)
	
	uiC.handle_menu_input(inputC.upgrade_menu)

	#inventoryC.isEquip = false
	#
	var menu_open = uiC.is_menu_open
	#
	#if inputC.interact and not menu_open:
		#var handled := interactC.process(delta, true)
		#if not handled:
			#inventoryC.isEquip = true
				#
			#for item in iArea.get_overlapping_bodies():
				#if item.is_in_group("Gear"):
					#upgradeC.pickupGear(item.gearData)
					#item.queue_free()


	if inputC.interact and not menu_open:
		interactC.process(delta, inputC.interact)

	menu_open = uiC.is_menu_open
	
	var can_block := (
		not menu_open and 
		not _weapon_is_attacking() and
		not staggerC.is_staggered and
		not dodgeC.is_dodging
	)
	
	blockC.update(
		inputC.block_held and can_block,
		inputC.block and can_block,
		delta
	)
	
	var riposte_consumed_attack = riposteC.update(
		delta,
		inputC.attack,
		_weapon_is_attacking(),
		not menu_open and 
		not blockC.is_blocking and 
		not dodgeC.is_dashing and 
		not staggerC.is_staggered
	)

	#inventoryC.isAttack = (inputC.attack and 
		#not menu_open and not dodgeC.is_dashing and 
		#not riposte_consumed_attack and 
		#not riposteC.is_active()
	#)
		
	#inventoryC.update(resolveC, anim, canStagger, canCombo, canCrit)

	var can_start_attack = not menu_open and not blockC.is_blocking and not dodgeC.is_dashing and not staggerC.is_staggered

	if inputC.attack and can_start_attack and not riposte_consumed_attack:
		attackC.Attack()

	if inputC.lock_on and not menu_open:
		lockOnC.toggle_target()
	
	lockOnC.update()
	
	if not menu_open:
		cameraC.update(self, delta)
		
	resolveC.update(delta)
	healthC.update(delta)
	attackC.process(delta)
	if inputC.use and not menu_open and healthC.current_health < healthC.max_health:
		if inventoryC.Heals > 0:
			healthC.heal(heal_amount)
			inventoryC.UseHeal()
			
	label_4.text = str(inventoryC.Heals)
	


func _physics_process(delta: float) -> void:
	if uiC.is_menu_open:
		dodgeC.cancel_dash()
		movementC.cancel_attack_lunge()
		velocity = Vector3.ZERO
		return

	TimeSinceDmg += delta
	

	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if inputC.dodge and riposteC.can_cancel_with_dodge():
		riposteC.cancel_with_dodge()
	
	if riposteC.physics_update(delta, self):
		return

	if staggerC.is_staggered:
		dodgeC.cancel_dash()
		movementC.cancel_attack_lunge()
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var move_input: Vector2
	
	if not SwitchControlAxes:
		move_input = Vector2(inputC.dir.x * invertControlsX, inputC.dir.y * invertControlsY)
	else:
		move_input = Vector2(inputC.dir.y * invertControlsY, inputC.dir.x * invertControlsX)
		
	var move_dir: Vector3	
	

	# LOCKING ON ENEMY
	if is_instance_valid(lockOnC.target):
		var to_target = lockOnC.target.global_position - global_position
		to_target.y = 0
		
		var forward: Vector3
		if to_target.length_squared() > 0.001:
			forward = to_target.normalized()
		else:
			forward = -global_basis.z
		
		var right = forward.cross(Vector3.UP).normalized()
		move_dir = (right * move_input.x - forward * move_input.y).limit_length(1.0)
	else:
		move_dir = cameraC.get_move_direction(move_input)
	


	# DODGING
	if inputC.dodge and not _weapon_is_attacking() and not blockC.is_blocking:
		var step_direction = move_dir

		if step_direction.length_squared() < 0.25:
			if is_instance_valid(lockOnC.target):
				step_direction = global_position - lockOnC.target.global_position
			else:
				step_direction = global_basis.z

		if dodgeC.start_dash(step_direction):
			var local_direction: Vector3 = global_basis.inverse() * step_direction
			local_direction.y = 0.0

			var dodge_anim: StringName = &"DodgeB"

			if absf(local_direction.z) > absf(local_direction.x):
				if local_direction.z < -0.25:
					dodge_anim = &"DodgeF"
			else:
				if local_direction.x < -0.25:
					dodge_anim = &"DodgeL"
				elif local_direction.x > 0.25:
					dodge_anim = &"DodgeR"
			
			animC.play_model_anim(dodge_anim)

	dodgeC.physics_update(delta)


	# MOVEMENT
	if not dodgeC.is_dashing:
		var dir_wanted = move_dir
		var should_rotate = not is_instance_valid(lockOnC.target)

		if attackC.isAttacking:
			dir_wanted = Vector3.ZERO
			should_rotate = false
		
		movementC.physics_update(delta, dir_wanted, self, should_rotate)

	elif attackC.isAttacking:
		velocity = Vector3.ZERO




	if is_instance_valid(lockOnC.target):
		var to_target = lockOnC.target.global_position - global_position
		to_target.y = 0
		
		if to_target.length_squared() > 0.001:
			var target_yaw := atan2(-to_target.x, -to_target.z)
			rotation.y = rotate_toward(rotation.y, target_yaw, 16.0 * delta)
	
	

	#if inputC.dir != Vector2.ZERO:
		#animC.process(true, false)
	#else:
		#animC.process(false, false)

	move_and_slide()

	# HANDLING WALK AND IDLE ANIMS

	var dodge_anim_playing = (animC.model_animation_player.is_playing() and str(animC.model_animation_player.current_animation).begins_with("Dodge"))

	if (
		not attackC.isAttacking
		and not blockC.is_blocking
		and not dodgeC.is_dashing
		and not staggerC.is_staggered
		and not dodge_anim_playing
	):
		var movement_anim: StringName = &"Idle"

		if move_dir.length_squared() > 0.01:
			movement_anim = &"Walk"
		
		animC.play_model_anim(movement_anim)

	####

	
func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction:Vector3 = Vector3.LEFT, attacker: Node3D = null, hit_collider: Node3D = null) -> void:
	await hitReponse.take_hit(damage, hit_stagger_duration, hit_direction, attacker, hit_collider)
	
func try_dodge_graze(attack: String) -> bool:
	if not dodgeC.can_graze_attack():
		return false
	
	if not grazed_attacks.has(attack):
		grazed_attacks[attack] = true
		resolveC.gainResolve(dodge_graze_resolve)
	
	return true

func finish_dodge_graze_attack(attack_id: String) -> void:
	grazed_attacks.erase(attack_id)

func _on_stagger_started() -> void:
	animC.play_model_anim(&"Stagger")

func _on_blocking_started() -> void:
	anim.play("Block")
	animC.play_model_anim(&"Block")

func _on_blocking_ended() -> void:
	if anim.current_animation == "Block":
		anim.play("Unblock")
		
func _weapon_is_attacking() -> bool:
	return attackC.isAttacking
	#return is_instance_valid(inventoryC.cWeapon) and inventoryC.cWeapon.isAttacking

func open_campfire_menu() -> void:
	uiC.open_campfire_menu()

func _on_refill_heals_pressed() -> void:
	inventoryC.Heals = max_heals 

func _on_hit_response_parry_succeeded(target: Node3D, target_staggered: StaggerComponent) -> void:
	parry_succeeded.emit(target, target_staggered)

func _on_riposte_feedback_requested(effect: StringName, target: Node3D) -> void:
	if effect != &"riposte_hit":
		return
	
	HitStop.request(0.12, 0.6)
	cameraC.push_in(0.7, 0.16)
	cameraC.shake(0.24, 0.18)


func onDeath():
	queue_free()
	print("Wow ma so bad you are")
	print("daeth")
	print("changed")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(load("uid://o73v2cty65b6")) 
	
func activate_hurtbox() -> void:
	inventoryC.cWeapon.activate_hurtbox()
func deactivate_hurtbox() -> void:
	inventoryC.cWeapon.deactivate_hurtbox()
