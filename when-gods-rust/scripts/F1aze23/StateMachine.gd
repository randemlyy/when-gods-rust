class_name StateMachine
extends Node

@export var iState:state
var cState:state
var states:Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is state:
			states[child.name.to_lower()] = child
			child.sm = self
	
	if iState:
		change_state(iState.name.to_lower())
 
func _process(delta: float) -> void:
	if cState:
		cState.update(delta)
	
func _physics_process(delta: float) -> void:
	if cState:
		cState.physics_update(delta)
	
func change_state(newStateName:String):
	if cState:
		cState.exit()
		
	cState = states.get(newStateName.to_lower())
	
	if cState:
		cState.enter()
	
