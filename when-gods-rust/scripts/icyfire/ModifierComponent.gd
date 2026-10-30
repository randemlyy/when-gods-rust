class_name ModifierComponent
extends Node

@onready var upgrade_component: UpgradeComponent = $"../UpgradeComponent"
@onready var inventory_component: InventoryComponent = $"../InventoryComponent"

@export var staggered_damage_multiplier: float = 1.3

var crit_window_open: bool = false
var queued_crit: bool = false
var is_current_attack_crit: bool = false

func open_crit_window() -> void:
	crit_window_open = true

func close_crit_window() -> void:
	crit_window_open = false

func register_attack_input() -> void:
	if crit_window_open:
		queued_crit = true
	print("Attack input registered. Window open: ", crit_window_open,
			" | Next attack crit: ", queued_crit)

func begin_attack() -> void:
	is_current_attack_crit = queued_crit
	print("Attack queued. Crit: ", is_current_attack_crit)
	queued_crit = false
	crit_window_open = false

func reset_attack_state() -> void:
	crit_window_open = false
	queued_crit = false
	is_current_attack_crit = false

func get_attack_damage(base_damage: int, target_is_staggered: bool, weapon_crit_multiplier: float) -> int:
	var damage_multiplier = 1.0

	if upgrade_component:
		damage_multiplier *= 1.0 + upgrade_component.get_effect_stat_bonus(StatModifierData.Stat.NORMAL_ATTACK_DAMAGE) / 100.0

	if is_current_attack_crit:
		damage_multiplier *= weapon_crit_multiplier
	
	if target_is_staggered:
		damage_multiplier *= staggered_damage_multiplier

	return roundi(base_damage * damage_multiplier)

func get_riposte_damage(base_damage: int) -> int:
	var damage_multiplier = 1.0

	if upgrade_component:
		var bonus = upgrade_component.get_stat_percent(StatModifierData.Stat.RIPOSTE_DAMAGE)
		damage_multiplier *= 1.0 + bonus / 100.0
	
	return roundi(base_damage * damage_multiplier)



