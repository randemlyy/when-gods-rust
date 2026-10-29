class_name LoadPenaltyComponent
extends Node

@onready var resolveC: ResolveComponent = $"../ResolveComponent"
@onready var upgradeC: UpgradeComponent = $"../UpgradeComponent"

@export_range(0.0, 100.0, 1.0) var max_damage_increase_percent: float = 50.0
@export_range(0.0, 100.0, 1.0) var max_resolve_drain_percent: float = 20.0
@export_range(0.0, 100.0, 1.0) var max_resolve_gain_percent: float = 20.0

func get_deficit_ratio() -> float:
	if resolveC.maxResolve <= 0.0:
		return 0.0
	
	var deficit = maxf(upgradeC.get_current_load() - resolveC.cResolve, 0.0)
	return clampf(deficit / resolveC.maxResolve, 0.0, 1.0)

func damage_taken_mult() -> float:
	var penalty = max_damage_increase_percent / 100.0
	penalty *= get_deficit_ratio() * upgradeC.get_load_penalty_multiplier()
	return 1.0 + penalty

func resolve_drain_mult() -> float:
	var penalty = max_damage_increase_percent / 100.0
	penalty *= get_deficit_ratio() * upgradeC.get_load_penalty_multiplier()
	return 1.0 + penalty