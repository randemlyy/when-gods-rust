extends CharacterBody3D

@onready var healthC: HealthComponent = $HealthComponent
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var movementC: MovementComponent = $MovementComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@export var isAttacking:=false
@onready var lootC: LootComponent = $LootComponent
# @onready var lootC: LootComponent = $LootComponent

func _ready() -> void:
	healthC.start()
	healthC.died.connect(death)

func _process(delta: float) -> void:
	if staggerC.is_staggered:
		if anim.current_animation != "Idle":
			anim.play("Idle")
	elif isAttacking:
		if anim.current_animation != "Attack":
			anim.play("Attack")
	elif movementC.isWalking:
		if anim.current_animation != "Walk":
			anim.play("Walk")
	else:
		if anim.current_animation != "Idle":
			anim.play("Idle")
	healthC.update(delta)
	
func death():
	lootC.grant_resources()
	queue_free()
