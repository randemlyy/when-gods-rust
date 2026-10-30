class_name ResolveDeficitEffect
extends GearEffectData

# Adds (damage_percent_per_deficit) for every point of Resolve lesser than the current load capacity
# the downside is higher load penalty
# consider adding a clamp for the boost, so people dont js go around with 1-2 resolve.

@export var damage_percent_per_deficit: float = 0.5
@export var load_penalty_multiplier: float = 1.5

func get_stat_bonus(stat: StatModifierData.Stat, player: Node) -> float:
    if stat != StatModifierData.Stat.NORMAL_ATTACK_DAMAGE:
        return 0.0
    
    var upgradeC = player.get_node_or_null("UpgradeComponent") as UpgradeComponent
    var resolveC = player.get_node_or_null("ResolveComponent") as ResolveComponent

    if upgradeC == null or resolveC == null:
        return 0.0
    
    var deficit = max(upgradeC.get_current_load() - resolveC.cResolve, 0.0)
    return deficit * damage_percent_per_deficit

func get_load_penalty_multiplier(player: Node) -> float:
    return load_penalty_multiplier