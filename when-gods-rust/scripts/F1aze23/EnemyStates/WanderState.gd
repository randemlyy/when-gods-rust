extends state

var body:CharacterBody3D
var dir:Vector3
@export var wTimer:Timer
@export var gCheck: RayCast3D


func enter():
	if get_parent().get_parent() is CharacterBody3D:
		body = get_parent().get_parent()
	else:
		print("no body")
	wTimer.start()
	wTimer.timeout.connect(randomDir)
		
func update(delta:float):
	if !gCheck.is_colliding():
		randomDir()
		body.move_and_slide()
	body.dir = dir

func randomDir():
	dir = Vector3(randf_range(-1, 1), 0.0, randf_range(-1, 1))
	wTimer.start()
	
