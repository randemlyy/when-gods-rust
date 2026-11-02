class_name CampfireMenu
extends Control

signal set_gears_pressed
signal refill_heals_pressed
signal exit_pressed
signal crafting_table_pressed

@onready var SetGearsButton: Button = $CenterContainer/PanelContainer/VBoxContainer/SetGearsButton
@onready var RefillHealsButton: Button = $CenterContainer/PanelContainer/VBoxContainer/RefillHealsButton
@onready var ExitButtton: Button = $CenterContainer/PanelContainer/VBoxContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SetGearsButton.pressed.connect(_on_set_gears_pressed)
	RefillHealsButton.pressed.connect(_on_heals_refill_pressed)
	ExitButtton.pressed.connect(_on_exit_pressed)

func open() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func close() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_set_gears_pressed() -> void:
	set_gears_pressed.emit()

func _on_heals_refill_pressed() -> void:
	refill_heals_pressed.emit()
	
func _on_crafting_table_pressed() -> void:
	crafting_table_pressed.emit()

func _on_exit_pressed() -> void:
	exit_pressed.emit()
