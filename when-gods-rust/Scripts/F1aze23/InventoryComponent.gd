class_name InventoryComponent
extends Node

@export var hand_slot: Node3D
@export var iArea:Area3D
@export var anim: AnimationPlayer

var cWeapon:Weapon = null
var isEquip:bool = false

func update():
	if not isEquip or iArea == null:
		return
	
	for item in iArea.get_overlapping_bodies():
		if not item.has_node("ItemWeapon"):
			continue
		
		equip(item.get_node("ItemWeapon"))
		item.queue_free()
		return

func equip(itemWeapon:Node):
	if not itemWeapon or not itemWeapon.Weapon or itemWeapon is not ItemWeapon:
		return
	if is_instance_valid(cWeapon):
		drop()
	var new_weapon = itemWeapon.Weapon.instantiate() as Weapon
	hand_slot.add_child(new_weapon)
	cWeapon = new_weapon
	print(cWeapon)

func play_attack(attack_index: int, is_crit: bool) -> void:
	if is_instance_valid(cWeapon):
		cWeapon.play_attack(attack_index, is_crit, anim)

func cancel_attack() -> void:
	if is_instance_valid(cWeapon):
		cWeapon.cancel_attack()

func drop():
	cWeapon.queue_free()
	#Imma do this for now ill implement drop logic later
