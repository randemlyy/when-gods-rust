class_name CameraComponent
extends Camera2D

@export var follow_speed: = 600.0
@export var look_ahead_distance: = 12.0
@export var look_ahead_response: = 10.0
@export var look_ahead_start_speed : = 20.0
@export var look_ahead_final_speed := 120

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed := player.velocity.length()
	var look_weight := inverse_lerp(
		look_ahead_start_speed,
		look_ahead_final_speed,
		speed
	)
	
	look_weight = smoothstep(0.0, 1.0, look_weight)
	
	var target_offset = Vector2.ZERO
	if speed > look_ahead_start_speed:
		target_offset = (
			player.velocity.normalized()
			* look_ahead_distance
			* look_weight
		)
	
	var blend = 1.0 - exp(-look_ahead_distance* delta)
	offset = offset.lerp(target_offset, blend)
