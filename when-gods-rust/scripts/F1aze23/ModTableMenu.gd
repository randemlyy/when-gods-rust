extends Control

@export var modCode:Label
@export var inventoryC:InventoryComponent
@export var codeInput:LineEdit
@export var outputText:Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_test_weapon_pressed() -> void:
	modCode.text = 'EAB7642'


func _on_code_enter_pressed() -> void:
	if codeInput.text == "CORE-7392":
		inventoryC.unlocked.append("TestWeapon")
		outputText.text = "TestWeapon Unlocked!"
	else:
		outputText.text = "Wrong Code, Try Again!"
	
	await get_tree().create_timer(2).timeout
	outputText.text = " "
		


func _on_back_pressed() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
