extends state

enum Phase {IDLE, WINDUP, ACTIVE, RECOVERY, COOLDOWN}



@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var hand_hitbox: Area3D = $"../../Zealot/Skeleton3D/BoneAttachment3D/Area3D"

@export var body:CharacterBody3D

@export_group("Attack Timings")
@export var windup_time: float = 0.38
@export var active_time: float = 0.16
@export var recovery_time: float = 0.14
@export var attack_cooldown: float = 0.55

@export_group ("Ranges")
@export var attack_trigger_range: float = 1.2
@export var leash_range: float = 14.0
@export var turn_speed: float = 8.0
@export var lunge_distance: float = 0.8

@export_group("Damage")
@export var damage: int = 10
@export var hit_stagger_duration: float = 0.6

@export var canAttack: bool = true

var phase: Phase = Phase.IDLE
var phase_left: float = 0.0
var player: CharacterBody3D
var move_dir: Vector3 = Vector3.ZERO
var hit_player: bool = false
var attack_serial: int = 0
var attack_id: String = ""


func enter() -> void:
	player = get_tree().get_first_node_in_group("Player") as CharacterBody3D
	phase = Phase.IDLE
	phase_left = 0.0
	move_dir = Vector3.ZERO
	hit_player = false
	attack_id = ""
	if body != null:
		body.isAttacking = false

func exit() -> void:
	if body != null:
		body.isAttacking = false
	
	_end_attack_id()
	phase = Phase.IDLE
	phase_left = 0.0
	move_dir = Vector3.ZERO
	hit_player = false

func update(delta: float) -> void:
	if body == null or not body.is_inside_tree():
		return
	
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as CharacterBody3D
		if not is_instance_valid(player):
			return
		
	var to_player: Vector3 = player.global_position - body.global_position
	to_player.y = 0.0
	var distance: float = to_player.length()

	match phase:
		Phase.IDLE:
			_face_player(to_player, delta)

			if distance > leash_range:
				move_dir = Vector3.ZERO
				sm.change_state("wander")
				return
			
			if distance <= attack_trigger_range:
				move_dir = Vector3.ZERO
				_begin_attack()
			else:
				move_dir = to_player.normalized()
		
		Phase.WINDUP:
			_face_player(to_player, delta)
			_advance(delta)
		
		Phase.ACTIVE:
			_scan_for_hit()
			_advance(delta)
		
		Phase.RECOVERY:
			_advance(delta)
		
		Phase.COOLDOWN:
			_face_player(to_player, delta)
			_advance(delta)
		
func physics_update(delta: float) -> void:
	if body == null or not body.is_inside_tree():
		return
	
	var dir: Vector3 = move_dir if phase == Phase.IDLE else Vector3.ZERO
	movementC.physics_update(delta, dir, body)
	body.move_and_slide()

func _advance(delta: float) -> void:
	phase_left -= delta
	if phase_left > 0.0:
		return
	
	match phase:
		Phase.WINDUP:
			phase = Phase.ACTIVE
			phase_left = active_time
			movementC.start_attack_lunge(lunge_distance, active_time)
		
		Phase.ACTIVE:
			phase = Phase.RECOVERY
			phase_left = recovery_time
		
		Phase.RECOVERY:
			_finish_attack()

		Phase.COOLDOWN:
			phase = Phase.IDLE
			phase_left = 0.0

func _begin_attack() -> void:
	phase = Phase.WINDUP
	phase_left = windup_time
	hit_player = false

	attack_serial += 1
	attack_id = "%s:%d" % [get_instance_id(), attack_serial]

	body.isAttacking = true
	anim.stop()
	anim.play("Attack")

func _finish_attack() -> void:
	body.isAttacking = false
	_end_attack_id()
	phase = Phase.COOLDOWN
	phase_left = attack_cooldown

func _end_attack_id() -> void:
	if attack_id.is_empty():
		return

	if is_instance_valid(player) and player.has_method("finish_dodge_graze_attack"):
		player.call("finish_dodge_graze_attack", attack_id)
	attack_id = ""

func _face_player(to_player: Vector3, delta: float) -> void:
	if to_player.length_squared() < 0.0001:
		return
	
	var target_yaw: float = atan2(-to_player.x, -to_player.z)
	body.rotation.y = rotate_toward(body.rotation.y, target_yaw, turn_speed * delta)

func _scan_for_hit() -> void:
	if hit_player or not is_instance_valid(player):
		return

	if _try_dodge_graze():
		return

	for target in hand_hitbox.get_overlapping_bodies():
		if target.is_in_group("Player"):
			onAttackHit(target)
			return

func _try_dodge_graze() -> bool:
	if not is_instance_valid(player):
		return false
	
	for area in hand_hitbox.get_overlapping_bodies():
		if not area.is_in_group("DodgeArea"):
			continue
		
		if area.get_parent() != player:
			continue
		
		if player.try_dodge_graze(attack_id):
			hit_player = true
			return true
	
	return false

func onAttackHit(node: Node3D) -> void:
	if hit_player or phase != Phase.ACTIVE:
		return
	if not is_instance_valid(player) or node != player:
		return
	if _try_dodge_graze():
		return

	hit_player = true
	var direction: Vector3 = (player.global_position - body.global_position).normalized()
	player.take_hit(damage, hit_stagger_duration, direction, body, node)
