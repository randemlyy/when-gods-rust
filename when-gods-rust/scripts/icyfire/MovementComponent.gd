class_name MovementComponent
extends Node


@onready var body: CharacterBody3D = $".."
@onready var inputC: InputComponent = $"../InputComponent"
@onready var attackC: AttackComponent = $"../AttackComponent"

@export var acceleration:float = 1500.0
@export var braking:float = 1800.0
@export var speed:float = 5.0

var MoveDir:Vector2
var grounded:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_process(delta: float, movedir:Vector3) -> void:
	if attackC.is_attacking:
		return
	grounded = body.is_on_floor()
	if grounded:
		body.velocity.x = speed * movedir.x
		body.velocity.z = speed * movedir.z
	pass
