class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

var max_health: int = 100

@export var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		died.emit()
