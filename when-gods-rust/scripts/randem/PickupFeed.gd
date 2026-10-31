class_name PickupFeed
extends Control

@onready var inventoryC: InventoryComponent = $"../../Components/InventoryComponent"
@onready var upgradeC: UpgradeComponent = $"../../Components/UpgradeComponent"
@onready var messages: VBoxContainer = $Messages


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventoryC.resource_added.connect(_show_resource)
	upgradeC.gear_added.connect(_show_gear)

func _show_resource(resource_name: String, amount: int) -> void:
	_show_message("+%d %s" % [amount, resource_name], Color.WHITE)

func _show_gear(gear: GearData) -> void:
	_show_message("Gear acquired: %s" % [gear.gear_name], Color.GOLD)

func _show_message(message: String, color: Color) -> void:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 36)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.03, 0.03, 0.8)
	style.border_color = color
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 10
	style.content_margin_right = 10

	panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.modulate = color

	panel.add_child(label)
	messages.add_child(panel)

	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(panel, "modulate:a", 0.0, 0.35)
	tween.tween_callback(panel.queue_free)
