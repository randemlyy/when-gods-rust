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
			var player = get_parent().get_parent() as Node3D
			if player == null:
				return false
			target.interact(player)
			return true
	
	return false
