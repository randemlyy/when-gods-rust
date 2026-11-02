extends Control

@onready var vBoxC: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@export var recipePool: Array[GearData]
@export var recipes:Array[Dictionary]
@export var upgradeC:UpgradeComponent
@export var inv:InventoryComponent

signal crafting_table_back_pressed

var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	for i in recipePool:
		recipes.append(i.recipe)
		CreateButton(i.recipe, str(i.gear_name), i)


func CreateButton(dict:Dictionary, name:String, gear:GearData):
	var button = load("res://scenes/F1aze23/CraftingButton.tscn").instantiate()
	vBoxC.add_child(button)
	button.upgradeC = upgradeC
	button.inv = inv
	button.get_node("Button").text = name
	button.get_node("Button").add_theme_font_size_override("font_size", 24)
	if button.is_inside_tree():print("Created button")
	button.create(dict, gear)
	
	
func toggle_menu() -> void:
	visible = not visible
	
	if visible:
		previous_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = previous_mouse_mode
	
func close() -> void:
	crafting_table_back_pressed.emit()
