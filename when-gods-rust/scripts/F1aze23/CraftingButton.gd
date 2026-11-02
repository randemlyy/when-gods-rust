class_name CraftingButton 
extends Control

@onready var vBoxC: VBoxContainer = $VBoxContainer
var upgradeC:UpgradeComponent
var gear:GearData
var inv:InventoryComponent
var resources:Dictionary
var recipe:Dictionary
@onready var button: Button = $Button

func _process(delta: float) -> void:
	resources = inv.resources

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
	for i in recipe:
		if not resources.has(i):
			var text = button.text
			button.text = "Not enough resources"
			await get_tree().create_timer(2).timeout
			button.text = text
			print("NO resource")
			return
		if resources[i] < recipe[i]:
			var text = button.text
			button.text = "Not enough resources"
			await get_tree().create_timer(2).timeout
			button.text = text
			return
	upgradeC.pickupGear(gear)
	
	
	
#
