extends CharacterBody3D

@onready var healthC: HealthComponent = $HealthComponent
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var movementC: MovementComponent = $MovementComponent
@export var isAttacking:=false

func _ready() -> void:
	healthC.start()
	healthC.died.connect(queue_free)

func _process(delta: float) -> void:
	var next_anim = "Idle"

	if isAttacking:
		next_anim = "Attack"
	elif movementC.isWalking:
		next_anim = "Walk"

	if anim.current_animation != next_anim:
		anim.play(next_anim)

	healthC.update(delta)
