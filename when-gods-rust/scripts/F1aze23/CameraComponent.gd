class_name CameraComponent
extends Node

@export var offset:Vector3
@export var rotation:Vector3
var cam:Camera3D
func start():
	cam = Camera3D.new()
	
	get_tree().root.add_child.call_deferred(cam)
	
	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.size = 14
	
	cam.make_current() 

func update(body:CharacterBody3D):
	cam.look_at(body.global_position)
	cam.global_position = body.global_position + offset
	cam.rotation = rotation
