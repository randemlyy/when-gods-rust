class_name UpgradeComponent
extends Node

signal load_changed(current_load: float, max_load: float)
signal loadout_changed
signal gear_added(gear: GearData)

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var arm_part: BodyPartData
@export var core_part: BodyPartData
@export var owned_gears: Array[GearData] = []

var arm_sockets: Array[GearData] = []
var core_sockets: Array[GearData] = []

var attack_damage_bonus: float = 0.0
var block_resolve_cost_reduction: float = 0.0

var stat_percents: Dictionary = {}

func _ready() -> void:
	if arm_part != null:
		arm_sockets.resize(maxi(arm_part.socket_count, 0))
	
	if core_part != null:
		core_sockets.resize(maxi(core_part.socket_count, 0))
	
	_notify_loadout_changed()

func get_current_load() -> float:
	var total = 0.0

	for gear in arm_sockets:
		if gear != null:
			total += gear.load
	
	for gear in core_sockets:
		if gear != null:
			total += gear.load
	
	return total

func get_stat_percent(stat: StatModifierData.Stat) -> float:
	return float(stat_percents.get(stat, 0.0))

func install_gear(gear: GearData, socket_index: int) -> bool:
	if gear == null or not owned_gears.has(gear):
		return false
	
	var installed = false

	match gear.slot:
		GearData.Slot.ARM:
			installed = _install_into(arm_sockets, gear, socket_index)
		
		GearData.Slot.CORE:
			installed = _install_into(core_sockets, gear, socket_index)
	
	if not installed:
		return false
	
	owned_gears.erase(gear)
	_apply_gear_effects(gear, true)
	_notify_loadout_changed()
	return true

func remove_gear(slot: GearData.Slot, socket_index: int) -> bool:
	var gear: GearData

	match slot:
		GearData.Slot.ARM:
			if socket_index < 0 or socket_index >= arm_sockets.size():
				return false
			
			gear = arm_sockets[socket_index]

			if gear == null:
				return false

			arm_sockets[socket_index] = null
		
		GearData.Slot.CORE:
			if socket_index < 0 or socket_index >= core_sockets.size():
				return false

			gear = core_sockets[socket_index]

			if gear == null:
				return false
			
			core_sockets[socket_index] = null
	
	_apply_gear_effects(gear, false)
	owned_gears.append(gear)
	_notify_loadout_changed()
	return true

func pickupGear(gear: GearData) -> void:
	if gear == null:
		return
	
	owned_gears.append(gear)
	gear_added.emit(gear)
	_notify_loadout_changed()

func _notify_loadout_changed() -> void:
	_recalculate_final_stats()
	load_changed.emit(get_current_load(), resolveC.maxResolve)
	loadout_changed.emit()

func _recalculate_final_stats() -> void:
	stat_percents.clear()

	_add_gear_modifiers(arm_sockets)
	_add_gear_modifiers(core_sockets)

	attack_damage_bonus = get_stat_percent(StatModifierData.Stat.NORMAL_ATTACK_DAMAGE)
	block_resolve_cost_reduction = -get_stat_percent(StatModifierData.Stat.BLOCK_RESOLVE_COST) / 100.0
	

func _add_gear_modifiers(sockets: Array[GearData]) -> void:
	for gear in sockets:
		if gear == null:
			return
		
		for modifier in gear.modifiers:
			if modifier == null:
				return
			
			var current = get_stat_percent(modifier.stat)
			stat_percents[modifier.stat] = current + modifier.percent

func _apply_gear_effects(gear: GearData, equipping: bool) -> void:
	var player = get_parent().get_parent()

	for effect in gear.effects:
		if effect == null:
			continue
		
		if equipping:
			effect.equipped(player)
		else:
			effect.unequipped(player)

func get_effect_stat_bonus(stat: StatModifierData.Stat) -> float:
	var player = get_parent().get_parent()
	var total = 0.0

	for sockets in [arm_sockets, core_sockets]:
		for gear in sockets:
			if gear == null:
				continue
			
			for effect in gear.effects:
				if effect != null:
					total += effect.get_stat_bonus(stat, player)
	
	return total

func get_load_penalty_multiplier() -> float:
	var player = get_parent().get_parent()
	var multiplier = 1.0

	for sockets in [arm_sockets, core_sockets]:
		for gear in sockets:
			if gear == null:
				continue
			
			for effect in gear.effects:
				if effect != null:
					multiplier *= effect.get_load_penalty_multiplier(player)

	return multiplier

func _install_into(sockets: Array[GearData], gear: GearData, socket_index: int) -> bool:
	if socket_index < 0 or socket_index >= sockets.size():
		return false
	
	if sockets[socket_index] != null:
		return false
	
	sockets[socket_index] = gear
	return true