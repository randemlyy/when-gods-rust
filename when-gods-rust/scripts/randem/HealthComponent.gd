class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
@export var current_health: int
@export var bar_change_speed: float = 60.0
@export var healthBar: ProgressBar
@export var ghostHealthBar: ProgressBar
@export var health_follow_delay: float = 0.35

var _health_follow_delay_left: float = 0.0

func start() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	if is_instance_valid(healthBar):
		healthBar.max_value = max_health
		healthBar.value = max_health
	if is_instance_valid(ghostHealthBar):
		ghostHealthBar.max_value = max_health
		ghostHealthBar.value = max_health
		
func update(delta: float) -> void:
	if is_instance_valid(ghostHealthBar):
		ghostHealthBar.max_value = max_health
		ghostHealthBar.value = move_toward(
			ghostHealthBar.value,
			float(current_health),
			bar_change_speed * delta
		)
	
	if _health_follow_delay_left > 0.0:
		_health_follow_delay_left = maxf(_health_follow_delay_left - delta, 0.0)
		return
	
	if is_instance_valid(healthBar):
		healthBar.max_value = max_health
		healthBar.value = move_toward(
			healthBar.value,
			float(current_health),
			bar_change_speed * delta
		)
		
func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	_health_follow_delay_left = health_follow_delay
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
		
func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	var healed_health = mini(current_health + amount, max_health)
	if healed_health == current_health:
		return
	
	current_health = healed_health
	health_changed.emit(current_health, max_health)
