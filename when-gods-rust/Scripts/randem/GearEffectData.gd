class_name GearEffectData
extends Resource

func equipped(_player: Node) -> void:
    pass

func unequipped(_player: Node) -> void:
    pass

func get_stat_bonus(_stat: StatModifierData.Stat, _player: Node) -> float:
    return 0.0

func get_load_penalty_multiplier(_player: Node) -> float:
    return 1.0