class_name AttackComponent
extends Node

@onready var inventoryC: InventoryComponent = $"../InventoryComponent"
@onready var modifierC: ModifierComponent = $"../ModifierComponent"
@onready var animC: AnimationComponent = $"../AnimationComponent"

@onready var test_anim_player: AnimationPlayer = $"../TestAnimPlayer"

@onready var cWeapon: Weapon = inventoryC.cWeapon

var comboStep:int = 0

func process():
	
	
	
	pass


func Attack():
	match comboStep:
		0:
			animC.play_anim("Attack1")
		1:
			animC.play_anim("Attack2")
		2:
			animC.play_anim("Attack3")
			comboStep = 0
	pass
