extends state

@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var aTimer: Timer = $"../../aTimer"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var attackDist: RayCast3D = $"../../AttackDist"
@onready var hand_hitbox: Area3D = $"../../Zealot/Skeleton3D/BoneAttachment3D/Area3D"

@export var canAttack := true
@export var body:CharacterBody3D

var player:CharacterBody3D
var hit:Node
var dir:Vector3
var attack_started = false
var attack_serial = 0
var attack_id = ""

func enter():
	player = get_tree().get_first_node_in_group("Player")
	nav.reparent(body)
	
func update(delta):
	if !body.is_inside_tree():
		return
	if player == null or not is_instance_valid(player):
		sm.change_state("wander")
		return
		
	nav.target_position = player.global_position
	
	if attackDist.is_colliding() and canAttack and not attack_started:
		Attack()
		return
	if nav.distance_to_target() > 7 and not attack_started:
		sm.change_state("wander")
		return
	if attack_started:
		if not canAttack:
			_try_dodge_graze()
			for target in hand_hitbox.get_overlapping_bodies():
				if target.is_in_group("Player"):
					onAttackHit(target)
		elif not body.isAttacking:
			player.finish_dodge_graze_attack(attack_id)
			attack_id = ""
			attack_started = false

	dir = (nav.get_next_path_position() - body.global_position).normalized()

func physics_update(delta:float):
	if not body.is_inside_tree():
		return
	
	movementC.physics_update(delta, dir, body)
	body.move_and_slide()
	
func Attack():
	if !canAttack or attack_started:
		return
	attack_serial += 1
	attack_id = "%s:%d" % [get_instance_id(), attack_serial]
	attack_started = true
	body.isAttacking = true
	hit = null

func _try_dodge_graze() -> bool:
	for area in hand_hitbox.get_overlapping_areas():
		if not area.is_in_group("DodgeArea"):
			continue
		if area.get_parent() != player:
			continue
		if player.try_dodge_graze(attack_id):
			hit = player
			return true
	return false

func onAttackHit(node: Node3D) -> void:
	if canAttack or player == null or hit == player:
		return
	
	if _try_dodge_graze():
		return

	if not node.is_in_group("Player"):
		return
	
	hit = player
	var direction = (player.global_position - body.global_position).normalized()
	player.take_hit(10, 0.6, direction, body, node)
