class_name Weapon
extends Node3D

var comboStep:int = 0
var canCombo:bool = false
var canCrit:bool = false
var canStagger:bool = false
var isAttacking = false

@export var attackArea:Area3D
@export var maxCombo:int = 3
@export var hit_stagger_duration: float = 0.65
@export var damage: float = 10.0
@export var target_group: StringName = &"Enemy"

var bodies_hit_this_swing: Array[Node3D] = []
var is_current_attack_crit: bool = false
var connected_anim: AnimationPlayer

func _ready() -> void:
	if attackArea == null:
		push_error('bradar put attack area')
		return
	attackArea.monitoring = false

func Attack(resolve:ResolveComponent, anim:AnimationPlayer):
	if not isAttacking:
		startAttack(anim, resolve)
	elif canCrit:
		comboStep+=1
		resolve.gainResolve(10)
		damage *= 1.1
		startAttack(anim, resolve)
	elif canCombo:
		comboStep+=1
		startAttack(anim, resolve)

func startAttack(anim_player:AnimationPlayer, resolve:ResolveComponent = null):
	if attackArea == null or anim_player == null:
		return
	_connect_animation_signal(anim_player)
	
	isAttacking = true
	bodies_hit_this_swing.clear()
	attackArea.set_deferred("monitoring", true)
	
	if comboStep >= maxCombo:
		comboStep = 0
		if is_instance_valid(resolve):
			resolve.gainResolve(15)
		
	var animName = "Attack_" + str(comboStep+1)
	anim_player.play(animName)

func play_attack(attack_index: int, is_crit: bool, anim_player: AnimationPlayer) -> void:
	if attackArea == null or anim_player == null:
		return
	
	_connect_animation_signal(anim_player)
	
	isAttacking = true
	is_current_attack_crit = is_crit
	bodies_hit_this_swing.clear()
	attackArea.set_deferred("monitoring", true)
	
	anim_player.play("Attack_" + str(attack_index + 1))
	
func cancel_attack() -> void:
	isAttacking = false
	comboStep = 0
	bodies_hit_this_swing.clear()
	if attackArea != null:
		attackArea.set_deferred("monitoring", false)
	if is_instance_valid(connected_anim):
		connected_anim.stop()

func _connect_animation_signal(anim_player: AnimationPlayer) -> void:
	if connected_anim == anim_player:
		return	
	if is_instance_valid(connected_anim):	
		if connected_anim.animation_finished.is_connected(_on_animation_finished):
			connected_anim.animation_finished.disconnect(_on_animation_finished)
	
	connected_anim = anim_player
	connected_anim.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	isAttacking = false
	comboStep = 0
	bodies_hit_this_swing.clear()
	
	attackArea.set_deferred("monitoring", false)

func _physics_process(delta: float) -> void:
	if not isAttacking or attackArea == null or not attackArea.monitoring:
		return
	
	for target in attackArea.get_overlapping_bodies():
		_try_hit(target)

func _try_hit(target: Node3D) -> void:
	if target in bodies_hit_this_swing:
		return
	if not target.is_in_group(target_group):
		return

	bodies_hit_this_swing.append(target)
	var final_damage := roundi(damage * (1.1 if is_current_attack_crit else 1.0))
	target.call("take_hit", final_damage, hit_stagger_duration)
	print("Body ", target, " has taken", damage)
