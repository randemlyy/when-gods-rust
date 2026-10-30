class_name InventoryMenu
extends Control

@onready var inventoryC: InventoryComponent = $"../../Components/InventoryComponent"
@onready var upgradeC: UpgradeComponent = $"../../Components/UpgradeComponent"
@onready var gear_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/TabContainer/Gears/GearList
@onready var resource_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/TabContainer/Resources/ResourceList
@onready var panel: PanelContainer = $CenterContainer/PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	inventoryC.inventory_changed.connect(refresh)
	upgradeC.loadout_changed.connect(refresh)
	$CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	refresh()

func toggle() -> void:
	visible = not visible

	if visible:
		refresh()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func refresh() -> void:
	_clear(gear_list)
	_clear(resource_list)

	for gear in upgradeC.owned_gears:
		var label = Label.new()
		label.text = "%s  |  %s gear  |  Load: %s" % [gear.gear_name, "Arm" if gear.slot == GearData.Slot.ARM else "Core", gear.load]
		gear_list.add_child(label)
	
	for resource_name in inventoryC.resources:
		var label = Label.new()

		label.text = "%s: %s" % [resource_name, inventoryC.resources[resource_name]]
		resource_list.add_child(label)
	
	var heals = Label.new()
	heals.text = "Heals: %d" % inventoryC.Heals
	resource_list.add_child(heals)


func _clear(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
