class_name PlayerUIController
extends Node

signal refill_heals_requested

@onready var campfire_menu: CampfireMenu = $"../../CanvasLayer/CampfireMenu"
@onready var upgrade_menu: UpgradeMenu = $"../../CanvasLayer/UpgradeMenu"
@onready var inventory_menu: InventoryMenu = $"../../CanvasLayer/InventoryMenu"

var is_menu_open: bool:
	get:
		return campfire_menu.visible or upgrade_menu.visible or inventory_menu.visible

func _ready() -> void:
	campfire_menu.set_gears_pressed.connect(_on_set_gears_pressed)
	campfire_menu.refill_heals_pressed.connect(_on_refill_heals_pressed)
	campfire_menu.exit_pressed.connect(campfire_menu.close)
	upgrade_menu.back_pressed.connect(_on_upgrade_back_pressed)

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
