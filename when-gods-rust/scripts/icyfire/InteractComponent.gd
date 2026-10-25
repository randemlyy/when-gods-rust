class_name InteractComponent
extends Node

@onready var interact_area: Area3D = $"../../InteractArea"


func process(delta: float, IsInteractInput:bool) -> bool:
	if not IsInteractInput:
		return false
	
	for body in interact_area.get_overlapping_bodies():
		var target: Node = body
		
		if not target.has_method("interact") and target.get_parent() != null:
			target = target.get_parent()
		
		if target.has_method("interact"):
			target.interact(get_parent())
			return true
	
	return false
