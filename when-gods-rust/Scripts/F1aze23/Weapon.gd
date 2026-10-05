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
var anim: AnimationPlayer

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
		print("crit")
		damage *= 1.1
		startAttack(anim, resolve)
	elif canCombo:
		comboStep+=1
		print("combo continued")
		startAttack(anim, resolve)
		
func startAttack(anim:AnimationPlayer, resolve:ResolveComponent):
	if attackArea == null or anim == null:
		return
	isAttacking = true
	bodies_hit_this_swing.clear()
	attackArea.set_deferred("monitoring", true)
	if comboStep >= maxCombo:
		comboStep = 0
		resolve.gainResolve(15)
	var animName = "Attack_" + str(comboStep+1)
	anim.play(animName)
	anim.animation_finished.connect(func(name:StringName):
		isAttacking = false
		bodies_hit_this_swing.clear()
		attackArea.set_deferred("monitoring", false)
		comboStep = 0
		)
	print(animName)

func _physics_process(delta: float) -> void:
	if not isAttacking or attackArea == null or not attackArea.monitoring:
		return
	
	for target in attackArea.get_overlapping_bodies():
		_try_hit(target)

func _try_hit(target: Node3D) -> void:
	if target in bodies_hit_this_swing or target.is_in_group("player"):
		return
	
	if not target.has_method("take_hit"):
		return
	
	bodies_hit_this_swing.append(target)
	target.call("take_hit", damage, hit_stagger_duration)
	print("Body ", target, " has taken", damage)
