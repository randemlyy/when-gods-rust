class_name MovementComponent
extends Node

@export var max_speed: float = 60.0
@export var acceleration: float = 100.0
@export var decceleration: float = 170.0
@export var turn_accel: float = 220.0

var dir: Vector2 = Vector2.ZERO
var speed_multiplier: float = 1.0
var movement_enabled: bool = true

func physics_update(body: CharacterBody2D, delta:float) -> void:
	var direction = dir.limit_length(1.0)
	
	if not movement_enabled:
		direction = Vector2.ZERO
	
	var target_velocity = direction * max_speed * speed_multiplier
	var rate = acceleration
	
	if direction == Vector2.ZERO:
		rate = decceleration
	elif body.velocity.length() > 10.0 and body.velocity.normalized().dot(direction) < 0.75:
		rate = turn_accel
	
	body.velocity = body.velocity.move_toward(target_velocity, rate * delta)
	body.move_and_slide()
