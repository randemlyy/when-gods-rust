class_name StatModifierData
extends Resource

enum Stat {
	NORMAL_ATTACK_DAMAGE,
	RIPOSTE_DAMAGE,
	BLOCK_RESOLVE_COST,
	RESOLVE_LOSS,
	RESOLVE_GAIN
}

@export var stat: Stat
@export_range(-100.0, 500.0, 0.1) var percent: float = 0.0

