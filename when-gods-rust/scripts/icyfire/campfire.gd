extends Node3D
@export var camPos: Node3D
@export var playerPos: Node3D

func interact(player:Node3D) -> void:
	var health = player.get_node("Components/HealthComponent") as HealthComponent
	if health != null:
		health.heal(health.max_health)
	player.open_campfire_menu()

#func Rest(player:Node3D) -> void:
	#player.global_position = playerPos.global_position
	#player.get_node("InventoryComponent").Heals = 4
	#pass
