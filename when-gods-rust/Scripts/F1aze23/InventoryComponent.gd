class_name InventoryComponent
extends Node

var cWeapon:Weapon = null
@export var hand_slot: Node3D
var isEquip:bool = false
@export var iArea:Area3D
var isAttack:bool = false
@export var anim: AnimationPlayer

func update(delta, canCombo:bool, canCrit:bool, canStagger:bool, resolve:ResolveComponent):
	if is_instance_valid(cWeapon):
		cWeapon.canCombo = canCombo
		cWeapon.canCrit = canCrit
		cWeapon.canStagger = canStagger
	if isEquip:
		print("equip")
		for i in iArea.get_overlapping_bodies():
			if i.has_node("ItemWeapon"):
				equip(i.get_node("ItemWeapon"))
				i.queue_free()
				
	if isAttack:
		if is_instance_valid(cWeapon):
			cWeapon.Attack(resolve, anim)

func equip(itemWeapon:Node):
	if not itemWeapon or not itemWeapon.Weapon or itemWeapon is not ItemWeapon:
		return
	if is_instance_valid(cWeapon):
		drop()
	var new_weapon = itemWeapon.Weapon.instantiate()
	hand_slot.add_child(new_weapon)
	cWeapon = new_weapon
	print(cWeapon)
	
func drop():
	cWeapon.queue_free()
	#Imma do this for now ill implement drop logic later
