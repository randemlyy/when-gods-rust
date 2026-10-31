class_name InventoryComponent
extends Node

signal inventory_changed
signal resource_added(resource_name: String, amount: int)

@export var cWeapon: Weapon
@export var iArea:Area3D
@export var resources: Dictionary = {}

var Heals: int = 3


func UseHeal() -> void:
	if Heals <= 0:
		return
	
	Heals -= 1
	inventory_changed.emit()

func add_resource(resource_name: String, amount: int) -> void:
	if resource_name.is_empty() or amount <= 0:
		return
	resources[resource_name] = resources.get(resource_name, 0) + amount
	resource_added.emit(resource_name, amount)
	inventory_changed.emit()

func remove_resource(resource_name: String, amount: int) -> bool:
	if resource_name.is_empty() or amount <= 0:
		return false
	var current: int = resources.get(resource_name, 0)
	if current < amount:
		return false

	resources[resource_name] = current - amount
	inventory_changed.emit()
	return true