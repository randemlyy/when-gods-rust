class_name Weapon
extends Node3D

var comboStep:int = 0
var canCombo:bool = false
var canCrit:bool = false
var canStagger:bool = false
var isAttacking = false

@export var attackArea:Area3D
@export var maxCombo:int = 3

func Attack(resolve:ResolveComponent, anim:AnimationPlayer):
	if not isAttacking:
		startAttack(anim)
	elif canCrit:
		comboStep+=1
		resolve.gainResolve(10)
		print("crit")
		startAttack(anim)
	elif canCombo:
		comboStep+=1
		print("combo continued")
		startAttack(anim)
		
func startAttack(anim:AnimationPlayer):
	isAttacking = true
	if comboStep >= maxCombo:
		comboStep = 0
	var animName = "Attack_" + str(comboStep+1)
	anim.play(animName)
	anim.animation_finished.connect(func(name:StringName):
		isAttacking = false
		comboStep = 0
		)
	print(animName)
