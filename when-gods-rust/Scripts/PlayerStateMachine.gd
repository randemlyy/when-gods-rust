class_name PlayerStateMachine
extends Node

signal state_changed(new_state: int)

enum State {
	IDLE,
	MOVING,
	DODGING,
	BLOCKING,
	ATTACKING
}

@onready var player: CharacterBody2D = get_parent()
@onready var input: InputComponent = $InputComponent
@onready var move: MovementComponent = $MovementComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
