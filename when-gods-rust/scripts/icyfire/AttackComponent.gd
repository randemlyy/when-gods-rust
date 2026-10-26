class_name AttackComponent
extends Node

@onready var inventoryC: InventoryComponent = $"../InventoryComponent"
@onready var modifierC: ModifierComponent = $"../ModifierComponent"
@onready var animC: AnimationComponent = $"../AnimationComponent"

@onready var test_anim_player: AnimationPlayer = $"../../TestAnimPlayer"

@onready var cWeapon: Weapon = inventoryC.cWeapon

var comboStep:int = 0
var comboTime:float = 0

var isAttacking:bool = false

var attack1done:bool = false
var attack2done:bool = false
var attack3done:bool = false
func process(delta:float) -> void:
	#if not animC.IsAnimPlaying():
	if comboStep == 1 and not attack1done:
		isAttacking = true
		await animC.play_anim("Attack1")
		attack1done = true
#		await get_tree().create_timer(0.2).timeouts
	elif comboStep == 2 and not attack2done:
		await animC.play_anim("Attack2")
		attack2done = true
	elif comboStep == 3 and not attack3done:
		await animC.play_anim("Attack3")
		attack1done = false
		attack2done = false
		comboStep = 0
		isAttacking = false
	pass
func Attack():
	if comboStep < 3 and not animC.animation_player.is_playing():
		comboStep += 1
	else:
		comboStep = 0
	pass
