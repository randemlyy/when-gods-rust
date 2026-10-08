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

var bodies_hit_this_swing: Array[Node3D] = []
var is_current_attack_crit: bool = false


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
		startAttack(anim, resolve)
	elif canCombo:
		comboStep+=1
		startAttack(anim, resolve)

func startAttack(anim:AnimationPlayer, resolve:ResolveComponent = null):
	if attackArea == null or anim == null:
		return
	isAttacking = true
	bodies_hit_this_swing.clear()
	
	if comboStep >= maxCombo:
		comboStep = 0
		if is_instance_valid(resolve):
			resolve.gainResolve(15)
		
	var animName = "Attack_" + str(comboStep+1)
	anim.play(animName)
	print(animName)
	anim.animation_finished.connect(func(name:StringName):
		isAttacking = false
		comboStep = 0
		attackArea.set_deferred("monitoring", false)
		)

func _physics_process(delta: float) -> void:
	if attackArea.monitoring:
		for target in attackArea.get_overlapping_bodies():
			_try_hit(target)
	if isAttacking and not canStagger:
		attackArea.set_deferred("monitoring", true)

func _try_hit(target: Node3D) -> void:
	if target in bodies_hit_this_swing:
		return
#	if not target.is_in_group("Enemy"):
#		return

	bodies_hit_this_swing.append(target)
	var final_damage := roundi(damage * (1.1 if canCrit else 1.0))
	if target.has_method("take_hit"):
		target.call("take_hit", final_damage, hit_stagger_duration)
		print("Body", target, " has taken", damage)
