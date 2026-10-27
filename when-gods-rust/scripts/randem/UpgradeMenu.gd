class_name UpgradeMenu
extends Control

signal back_pressed

@onready var upgradeC: UpgradeComponent = $"../../Components/UpgradeComponent"
@onready var gear_list: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/InventoryColumn/ScrollContainer/GearList
@onready var arm_sockets: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/ArmColumn/ArmSockets
@onready var core_sockets: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/CoreColumn/CoreSockets
@onready var back_button: Button = $CenterContainer/PanelContainer/HBoxContainer/InventoryColumn/BackButton

var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgradeC.loadout_changed.connect(_refresh_menu)
	back_button.pressed.connect(_on_back_pressed)
	_refresh_menu()

func toggle_menu() -> void:
	visible = not visible
	
	if visible:
		previous_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = previous_mouse_mode

func _refresh_menu() -> void:
	_clear_children(gear_list)
	_clear_children(arm_sockets)
	_clear_children(core_sockets)
	
	for gear in upgradeC.owned_gears:
		var button = GearInventoryButton.new()
		button.gear = gear
		button.text = "%s | Load: %s" % [gear.gear_name, gear.load]
		gear_list.add_child(button)
	
	
	_add_socket_buttons(arm_sockets, upgradeC.arm_sockets, "Arm", GearData.Slot.ARM)
	_add_socket_buttons(core_sockets, upgradeC.core_sockets, "Core", GearData.Slot.CORE)

func _add_socket_buttons(container: VBoxContainer, sockets: Array[GearData], part_name: String, slot_type: GearData.Slot) -> void:
	for i in range(sockets.size()):
		var button = GearSocketButton.new()
		button.upgradeC = upgradeC
		button.slot_type = slot_type
		button.socket_index = i
		var gear : GearData = sockets[i]
		
		if gear == null:
			button.text = "%s Socket %d - Empty" % [part_name, i + 1]
		else:
			button.text = "%s Socket %d — %s" % [part_name, i + 1, gear.gear_name]
			button.pressed.connect(upgradeC.remove_gear.bind(slot_type, i))
		container.add_child(button)

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	
func _on_back_pressed() -> void:
	back_pressed.emit()
