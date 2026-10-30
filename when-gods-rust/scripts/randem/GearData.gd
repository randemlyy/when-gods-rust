class_name GearData
extends Resource

enum Slot {
	ARM,
	CORE
}

# General details
@export_group("Details")
@export var gear_name: String = "Unnamed Gear"
@export_multiline var description: String = ""
@export var slot: Slot = Slot.ARM
@export_range(0.0, 100.0, 0.1) var load: float = 0.0


# Stat changes
@export_group("Modifiers")
@export var modifiers: Array[StatModifierData] = []

# Unique effects
@export_group("Special Effects")
@export var effects: Array[GearEffectData] = []