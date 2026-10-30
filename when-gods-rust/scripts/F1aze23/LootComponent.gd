class_name  LootComponent
extends Node

@export var lootTable:Dictionary
@export var body:CharacterBody3D
@export var scrap_min: int = 1
@export var scrap_max: int = 5

@export var bonus_resource_name: String = ""
@export_range(0.0, 100.0, 1.0) var bonus_drop_chance: float = 0.0
@export var bonus_min: int = 1
@export var bonus_max: int = 1

func grant_resources() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	
	var inventoryC = player.get_node_or_null("Components/InventoryComponent") as InventoryComponent
	if inventoryC == null:
		return
	
	inventoryC.add_resource("Scrap", randi_range(scrap_min, scrap_max))

	if bonus_resource_name.is_empty():
		return
	
	if randf_range(0.0, 100.0) < bonus_drop_chance:
		inventoryC.add_resource(bonus_resource_name, randi_range(bonus_min, bonus_max))
	
	print(inventoryC.resources)

# func spawnLoot():
# 	var roll = randf_range(0.0,100.0)
# 	var totalWeight = 0.0
# 	for i in lootTable:
# 		totalWeight+=lootTable[i]
# 		if roll <= totalWeight:
# 			var inst = i.instantiate()
# 			get_tree().root.add_child(inst)
# 			inst.global_position = body.global_position 
# 			print("Successfully spawned: ", inst.name)
# 			break
		
