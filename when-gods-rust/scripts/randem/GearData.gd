class_name GearData
extends Resource

enum Slot {
	ARM,
	CORE
}

@export_group("Identity")
@export var gear_name: String = "Unnamed Gear"
@export_multiline var description: String = ""
@export var slot: Slot = Slot.ARM
@export_range(0.0, 100.0, 0.1) var load: float = 0.0

@export_group("Modifiers")
@export var modifiers: Array[StatModifierData] = []

@export_group("Special Effects")
@export var effects: Array[GearEffectData] = []

@export_group("Old")
@export var attack_damage_bonus: float = 0.0
@export var block_resolve_cost_reduction: float = 0.0