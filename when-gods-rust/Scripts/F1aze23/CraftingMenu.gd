extends Control

@onready var scrollC: ScrollContainer = $VBoxContainer/ScrollContainer
@export var recipePool: Array[GearData]
@export var recipes:Array[Dictionary]

func _ready() -> void:
	for i in recipePool:
		recipes.append(i.recipe)
		CreateButton(i.recipe, str(recipePool))


func CreateButton(dict:Dictionary, name:String):
	var button = load("res://Scenes/F1aze23/CraftingButton.tscn").instantiate()
	scrollC.add_child(button)
	button.get_node("Button").text = name
	if button.is_inside_tree():print("Created button")
	button.create(dict)
