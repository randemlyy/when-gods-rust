extends CharacterBody2D

@export var input: InputComponent
@onready var move: MovementComponent = $MovementComponent

func _physics_process(delta: float) -> void:
	move.dir = input.dir
	move.physics_update(self, delta)
	
