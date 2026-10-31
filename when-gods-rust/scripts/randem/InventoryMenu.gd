class_name InventoryMenu
extends Control

@onready var inventoryC: InventoryComponent = $"../../Components/InventoryComponent"
@onready var upgradeC: UpgradeComponent = $"../../Components/UpgradeComponent"

@onready var gear_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/TabContainer/Gears/GearList
@onready var resource_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/TabContainer/Resources/ResourceList
@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var title: Label = $CenterContainer/PanelContainer/VBoxContainer/Title
@onready var tabs: TabContainer = $CenterContainer/PanelContainer/VBoxContainer/TabContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	$CenterContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventoryC.inventory_changed.connect(refresh)
	upgradeC.loadout_changed.connect(refresh)

	title.text = "INVENTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)

	tabs.set_tab_title(0, "GEARS")
	tabs.set_tab_title(1, "RESOURCES")


	var menu_style = StyleBoxFlat.new()

	menu_style.bg_color = Color(0.025, 0.03, 0.045, 0.96)
	menu_style.border_color = Color(0.45, 0.58, 0.72, 0.9)
	menu_style.set_border_width_all(2)
	menu_style.corner_radius_bottom_left = 8
	menu_style.corner_radius_bottom_right = 8
	menu_style.corner_radius_top_left = 8
	menu_style.corner_radius_top_right = 8
	menu_style.content_margin_bottom = 14
	menu_style.content_margin_right = 18
	menu_style.content_margin_left = 18
	menu_style.content_margin_top = 14
	panel.add_theme_stylebox_override("panel", menu_style)
	
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
		_add_gear_card(gear, "Stored")
	
	for gear in upgradeC.arm_sockets:
		if gear != null:
			_add_gear_card(gear, "Equipped • Arm")
	
	for gear in upgradeC.core_sockets:
		if gear != null:
			_add_gear_card(gear, "Equipped • Core")

	if gear_list.get_child_count() == 0:
		_add_empty_message(gear_list, "No gears collected")
	
	if inventoryC.resources.is_empty():
		_add_empty_message(resource_list, "No resouces collected")
	else:
		for resource_name in inventoryC.resources:
			_add_resource_card(resource_name, inventoryC.resources[resource_name])

	_add_resource_card("Heals", inventoryC.Heals)

func _add_gear_card(gear: GearData, status: String) -> void:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 76)
	card.add_theme_stylebox_override("panel", _card_style(Color(0.72, 0.58, 0.2)))

	var content = VBoxContainer.new()
	card.add_child(content)

	var name_label = Label.new()
	name_label.text = gear.gear_name
	name_label.add_theme_font_size_override("font_size", 18)
	content.add_child(name_label)

	var details = Label.new()
	details.text = "%s • Load: %s" % [status, gear.load]
	details.modulate = Color(0.72, 0.78, 0.86)
	content.add_child(details)

	if not gear.description.is_empty():
		var desc = Label.new()
		desc.text = gear.description
		desc.modulate = Color(0.8, 0.8, 0.8)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(desc)
	
	gear_list.add_child(card)

func _add_resource_card(resource_name: String, amount: int) -> void:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 42)
	card.add_theme_stylebox_override("panel", _card_style(Color(0.35, 0.65, 0.82)))

	var row = HBoxContainer.new()
	card.add_child(row)

	var name_label = Label.new()
	name_label.text = resource_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 17)
	row.add_child(name_label)

	var amount_label = Label.new()
	amount_label.text = "x%d" % amount
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.modulate = Color(0.7, 0.88, 1.0)
	amount_label.add_theme_font_size_override("font_size", 17)
	row.add_child(amount_label)

	resource_list.add_child(card)

func _add_empty_message(container: VBoxContainer, message: String) -> void:
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.55, 0.6, 0.68)
	label.add_theme_font_size_override("font_size", 18)
	container.add_child(label)


func _card_style(border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.14, 0.95)
	style.border_color = border_color
	style.set_border_width_all(1)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _clear(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
