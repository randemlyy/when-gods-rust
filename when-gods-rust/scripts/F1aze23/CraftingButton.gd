class_name CraftingButton 
extends Control

@onready var vBoxC: VBoxContainer = $VBoxContainer
@onready var button: Button = $Button

var upgradeC:UpgradeComponent
var gear:GearData
var inv:InventoryComponent
var recipe:Dictionary

var _crafting = false

func create(dict: Dictionary, gearData:GearData) -> void:
	recipe = dict
	gear = gearData

	for child in vBoxC.get_children():
		child.queue_free()
		
	for key in dict:
		var hBox := HBoxContainer.new()
		vBoxC.add_child(hBox)
		
		var res := Label.new()
		res.text = str(key)
		hBox.add_child(res)
		
		var amt := Label.new()
		amt.text = str(dict[key])
		hBox.add_child(amt)


func onClick():
	if _crafting:
		return
	if gear == null or upgradeC == null or inv == null:
		return
	
	if not _can_afford():
		await _flash("Not enough resources!")
		return
	
	_crafting = true
	button.disabled = true

	var spent: Dictionary = {}
	for key in recipe:
		var resource_name = str(key)
		var amount: int = int(recipe[key])

		if inv.remove_resource(resource_name, amount):
			spent[resource_name] = amount
		
		else:
			for paid_name in spent:
				inv.add_resource(paid_name, int(spent[paid_name]))
			button.disabled = false
			_crafting = false
			await _flash("Not enough resources!")
			return

	var crafted = gear.duplicate(true) as GearData
	upgradeC.pickupGear(crafted)

	button.disabled = false
	_crafting = false
	await _flash("Crafted: " + gear.gear_name)

func _can_afford() -> bool:
	for key in recipe:
		if int(inv.resources.get(str(key)) < int(recipe[key])):
			return false

	return true

func _flash(message: String) -> void:
	var original: String = button.text
	button.text = message
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(button):
		button.text = original

