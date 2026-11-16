class_name PlayerUIController
extends Node

signal refill_heals_requested

@onready var campfire_menu: CampfireMenu = $"../../CanvasLayer/CampfireMenu"
@onready var upgrade_menu: UpgradeMenu = $"../../CanvasLayer/UpgradeMenu"
@onready var inventory_menu: InventoryMenu = $"../../CanvasLayer/InventoryMenu"
@onready var crafting_menu: Control = $"../../CanvasLayer/CraftingMenu"

@onready var riposteC: RiposteComponent = $"../RiposteComponent"

var _feedback_layer: CanvasLayer
var _feedback_label: Label
var _feedback_tween: Tween 

var is_menu_open: bool:
	get:
		return (
			campfire_menu.visible
			or upgrade_menu.visible
			or inventory_menu.visible
			or crafting_menu.visible
		)

func _ready() -> void:
	campfire_menu.set_gears_pressed.connect(_on_set_gears_pressed)
	campfire_menu.refill_heals_pressed.connect(_on_refill_heals_pressed)
	campfire_menu.exit_pressed.connect(campfire_menu.close)
	upgrade_menu.back_pressed.connect(_on_upgrade_back_pressed)
	crafting_menu.crafting_table_back_pressed.connect(_on_crafting_table_back_pressed)
	campfire_menu.crafting_table_pressed.connect(_on_crafting_table_pressed)

	_build_feedback_label()
	
	if is_instance_valid(riposteC):
		riposteC.riposte_window_opened.connect(_on_riposte_window_opened)
		riposteC.riposte_window_closed.connect(_on_riposte_window_closed)
	
func handle_menu_input(toggle_pressed: bool) -> void:
	if not toggle_pressed:
		return
	
	if campfire_menu.visible:
		campfire_menu.close()
	elif upgrade_menu.visible:
		upgrade_menu.toggle_menu()

func handle_inventory_input(toggle_pressed: bool) -> void:
	if not toggle_pressed:
		return
	
	if campfire_menu.visible or upgrade_menu.visible:
		return
	
	inventory_menu.toggle()

func open_campfire_menu() -> void:
	campfire_menu.open()

func _on_set_gears_pressed() -> void:
	campfire_menu.close()
	upgrade_menu.toggle_menu()

func _on_refill_heals_pressed() -> void:
	refill_heals_requested.emit()

func _on_upgrade_back_pressed() -> void:
	upgrade_menu.toggle_menu()
	campfire_menu.open()

func _on_crafting_table_pressed():
	crafting_menu.toggle_menu()
	
func _on_crafting_table_back_pressed():
	crafting_menu.toggle_menu()
	campfire_menu.open()

func _build_feedback_label() -> void:
	_feedback_layer = CanvasLayer.new()
	_feedback_layer.name = "CombatFeedbackLayer"
	_feedback_layer.layer = 10
	add_child(_feedback_layer)

	_feedback_label = Label.new()
	_feedback_label.name = "CombatFeedback"
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.anchor_left = 0.0
	_feedback_label.anchor_right = 1.0
	_feedback_label.anchor_top = 0.0
	_feedback_label.anchor_bottom = 0.0
	_feedback_label.offset_top = 96.0
	_feedback_label.offset_bottom = 136.0
	_feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_feedback_label.add_theme_font_size_override("font_size", 28)
	_feedback_label.modulate.a = 0.0
	_feedback_layer.add_child(_feedback_label)

func _on_riposte_window_opened(_target: Node3D) -> void:
	if _feedback_label == null:
		return
	
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	
	_feedback_label.text = "RIPOSTE"
	_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_feedback_label.modulate.a = 1.0

func _on_riposte_window_closed(_target: Node3D) -> void:
	if _feedback_label == null or _feedback_label.modulate.a <= 0.0:
		return
	
	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(_feedback_label, "modulate:a", 0.0, 0.2)
	
