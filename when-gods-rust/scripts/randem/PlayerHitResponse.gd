class_name PlayerHitResponse
extends Node

signal parry_succeeded(target: Node3D, target_staggered: StaggerComponent)

const PARRY_SPARK = preload("res://Assets/Randemlyy/ParrySpark.tscn")

@export var parry_stagger_duration: float = 1.2

@onready var player: CharacterBody3D = get_parent().get_parent() as CharacterBody3D
@onready var healthC: HealthComponent = $"../HealthComponent"
@onready var blockC: BlockComponent = $"../BlockComponent"
@onready var resolveC: ResolveComponent = $"../ResolveComponent"
@onready var staggerC: StaggerComponent = $"../StaggerComponent"
@onready var load_penaltyC: LoadPenaltyComponent = $"../LoadPenaltyComponent"
@onready var cameraC: CameraComponent = $"../CameraComponent"
@onready var animationC: AnimationComponent = $"../AnimationComponent"
@onready var dodgeC: DodgeComponent = $"../DodgeComponent"

func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction: Vector3 = Vector3.LEFT, attacker: Node3D = null, hit_collider: Node3D = null) -> void:
	var impact_time = float(Time.get_ticks_usec()) / 1_000_000
	var was_blocking = blockC.is_blocking

	if dodgeC.has_iframes():
		return

	await get_tree().create_timer(blockC.late_parry_window).timeout
	await get_tree().process_frame

	if not is_inside_tree():
		return
	
	if blockC.check_parry_press(impact_time):
		resolveC.gainResolve(blockC.resolve_on_parry)

		if is_instance_valid(attacker):
			var enemy_stagger = attacker.get_node_or_null("StaggerComponent") as StaggerComponent
			if enemy_stagger:
				enemy_stagger.apply_stagger(parry_stagger_duration)
				parry_succeeded.emit(attacker, enemy_stagger)
		
		HitStop.request(0.1, 0.3)
		_spawn_parry_spark(attacker)
		cameraC.shake(0.16, 0.12)
		return
	
	if was_blocking and blockC.spend_for_block():
		return
	
	var final_damage = roundi(damage * load_penaltyC.damage_taken_mult())
	healthC.take_damage(final_damage)
	cameraC.shake(0.12, 0.18)
	staggerC.apply_stagger(hit_stagger_duration)
	#animationC.process(false, true)
	player.velocity = hit_direction

func _spawn_parry_spark(target: Node3D) -> void:
	var spark = PARRY_SPARK.instantiate() as GPUParticles3D
	get_tree().current_scene.add_child(spark)

	if is_instance_valid(target):
		spark.global_position = player.global_position.lerp(target.global_position, 0.5) + Vector3.UP * 0.8
	else:
		spark.global_position = player.global_position + Vector3.UP
	
	spark.restart()
