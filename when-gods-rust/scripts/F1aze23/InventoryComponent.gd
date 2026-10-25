class_name InventoryComponent
extends Node

@onready var upgradeC: UpgradeComponent = $"../UpgradeComponent"

@export var cWeapon: Weapon = null
@onready var hand: Node3D = $"../Model2/WGR4/Armature/Skeleton3D/Bone_004_R/Hand"



#
#@onready var upgradeC: UpgradeComponent = $"../UpgradeComponent"
#
#@export var hand_slot: Node3D
#@export var iArea:Area3D
#@export var anim: AnimationPlayer
#@onready var label_4: Label = $"../CanvasLayer/Control/Label4"
#
#var cWeapon:Weapon = null
#var isEquip:bool = false
#var isAttack:bool = false
#
#var Heals:int = 3
#
#func update(resolve:ResolveComponent, anim:AnimationPlayer, canStagger:bool, canCombo:bool, canCrit:bool):
	#if is_instance_valid(cWeapon):
		#if isAttack:
			#cWeapon.Attack(resolve, anim)
		#cWeapon.canCombo = canCombo
		#cWeapon.canCrit = canCrit
		#cWeapon.canStagger = canStagger
	#if not isEquip or iArea == null:
		#return
	#for item in iArea.get_overlapping_bodies():
		#if not item.has_node("ItemWeapon"):
			#continue
		#equip(item.get_node("ItemWeapon"))
		#item.queue_free()
		#return
#
#func equip(itemWeapon:Node):
	#if not itemWeapon or not itemWeapon.Weapon or itemWeapon is not ItemWeapon:
		#return
	#if is_instance_valid(cWeapon):
		#drop()
	#var new_weapon = itemWeapon.Weapon.instantiate() as Weapon
	#new_weapon.upgradeC = upgradeC
	#hand_slot.add_child(new_weapon)
	#cWeapon = new_weapon
	#print(cWeapon)
#
#func drop():
	#cWeapon.queue_free()
	##Imma do this for now ill implement drop logic later
#
#func UseHeal() -> void:
	#if Heals > 0:
		#Heals -= 1
