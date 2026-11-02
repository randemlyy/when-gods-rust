extends StaticBody3D

var spawnPoints:Array[Transform3D] = []
@onready var spawnPointsHolder: Node3D = $SpawnPoints
var zealot = "res://Scenes/F1aze23/Zealot.tscn"
var monoculus = "res://Scenes/F1aze23/Monoculus.tscn"
@onready var spawns: Node3D = $Spawns
var canSpawn = true

func _ready() -> void:
	for i in spawnPointsHolder.get_children():
		spawnPoints.append(i.global_transform)
		
func spawn(rand:int, pos:Transform3D):
	if rand == 1:
		var spawn = load(zealot).instantiate()
		spawns.add_child(spawn)
		spawn.global_transform = pos
	elif rand == 2:
		var spawn = load(monoculus).instantiate()
		spawns.add_child(spawn)
		spawn.global_transform = pos
		
func _process(delta: float) -> void:
	if !canSpawn:
		return
	if spawns.get_children() != []:
		return
	for i in spawnPoints:
		var rand = randi_range(1, 2)
		spawn(rand, i)
	await get_tree().create_timer(15).timeout

func interact(_player:CharacterBody3D):
	canSpawn = false
	
