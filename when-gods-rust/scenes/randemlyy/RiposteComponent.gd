class_name RiposteComponent
extends Node

signal riposte_window_opened(target: Node3D)
signal riposte_window_closed(target: Node3D)
signal feedback_requested(effect: StringName, target: Node3D)

enum Phase {
	NONE,
	LUNGE,
	HIT_DELAY,
	RECOVERY
}

@export var attack_buffer = 0.15
@export var riposte_range = 2.5
@export var lunge_distance = 2.5
@export var lunge_time = 0.12
@export var hit_delay = 0.15
@export var recovery_time = 0.45
@export var dodge_cancel_time = 0.15
@export var stop_distance = 0.65
@export var front_dot_min = 0.35
@export var riposte_damage = 50
@export var animation_name: StringName = &"Riposte"

@onready var player: CharacterBody3D = get_parent().get_parent() as CharacterBody3D
@onready var anim: AnimationPlayer = $"../../TestAnimPlayer"
@onready var modifierC: ModifierComponent = $"../ModifierComponent"


var targets: Dictionary = {}
var buffer_left = 0.0
var pending = false

var phase: Phase = Phase.NONE
var phase_left = 0.0
var target: Node3D
var lunge_velocity = Vector3.ZERO

func is_active() -> bool:
	return phase != Phase.NONE

func on_parry(enemy: Node3D, stagger: StaggerComponent) -> void:
	if not is_instance_valid(enemy) or not is_instance_valid(stagger):
		return
	if not stagger.is_staggered:
		return
	
	var id = enemy.get_instance_id()
	if targets.has(id):
		return

	targets[id] = {"enemy": enemy, "stagger": stagger}

	var cleanup = Callable(self, "_remove_target").bind(id)
	enemy.tree_exiting.connect(cleanup)
	stagger.stagger_ended.connect(cleanup)

	var health = enemy.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		health.died.connect(cleanup)
	
	riposte_window_opened.emit(enemy)
	print("Riposte window opened for: ", enemy.name)

	if buffer_left > 0.0:
		buffer_left = 0.0
		pending = true

func update(delta: float, attack_pressed: bool, is_attacking: bool, can_start: bool) -> bool:
	buffer_left = maxf(buffer_left - delta, 0.0)

	if is_active():
		return attack_pressed
	
	var finished = false

	if attack_pressed:
		var candidate = _find_target() if can_start else null
		if candidate:
			pending = true
			buffer_left = 0.0
			finished = true
		elif can_start:
			buffer_left = attack_buffer
	
	if not pending and buffer_left > 0.0 and _find_target():
		pending = true
		buffer_left = 0.0

	if pending:
		var candidate = _find_target()
		if not candidate:
			pending = false
		elif can_start and not is_attacking:
			pending = false
			_start(candidate)
	
	return finished

func can_cancel_with_dodge() -> bool:
	return phase == Phase.RECOVERY and phase_left <= dodge_cancel_time

func cancel_with_dodge() -> void:
	if can_cancel_with_dodge():
		_finish()

func physics_update(delta: float, body: CharacterBody3D) -> bool:
	if not is_active():
		return false
	
	if phase != Phase.RECOVERY and not is_instance_valid(target):
		_finish()
		return false
	
	if phase == Phase.LUNGE:
		body.velocity.x = 0.0
		body.velocity.z = 0.0

		if body.move_and_collide(lunge_velocity * delta):
			lunge_velocity = Vector3.ZERO
		
		if absf(body.velocity.y) > 0.001:
			body.move_and_collide(Vector3.UP * body.velocity.y * delta)
	
	elif phase == Phase.HIT_DELAY:
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		body.move_and_slide()

	elif phase == Phase.RECOVERY:
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		body.move_and_slide()
	
	phase_left -= delta
	if phase_left > 0.0:
		return true

	if phase == Phase.LUNGE:
		phase = Phase.HIT_DELAY
		phase_left = hit_delay
	elif phase == Phase.HIT_DELAY:
		_hit()
	elif phase == Phase.RECOVERY:
		_finish()

	return true

func _start(enemy: Node3D) -> void:
	target = enemy
	phase = Phase.LUNGE
	phase_left = lunge_time

	var direction = enemy.global_position - player.global_position
	direction.y = 0.0
	var distance = direction.length()

	if distance > 0.001:
		direction = direction.normalized()
	else:
		direction = -player.global_basis.z

	var travel = minf(lunge_distance, maxf(0.0, distance - stop_distance))
	lunge_velocity = direction * travel / maxf(lunge_time, 0.001)

	var stagger = enemy.get_node_or_null("StaggerComponent") as StaggerComponent
	if stagger:
		stagger.apply_stagger(lunge_time + hit_delay + 0.05)
	if anim.has_animation(animation_name):
		anim.play(animation_name)

func _hit() -> void:
	var enemy = target
	if not is_instance_valid(enemy):
		_finish()
		return
	

	var stagger := enemy.get_node_or_null("StaggerComponent") as StaggerComponent
	var health := enemy.get_node_or_null("HealthComponent") as HealthComponent

	if not stagger or not stagger.is_staggered or not health or health.current_health <= 0:
		_finish()
		return
	
	phase = Phase.RECOVERY
	phase_left = recovery_time

	feedback_requested.emit(&"riposte_hit", enemy)
	health.take_damage(modifierC.get_riposte_damage(riposte_damage))

func _find_target() -> Node3D:
	var best: Node3D
	var best_distance = INF

	for id in targets.keys():
		var entry: Dictionary = targets[id]
		var enemy := entry["enemy"] as Node3D
		var stagger = entry["stagger"] as StaggerComponent

		if not is_instance_valid(enemy) or not is_instance_valid(stagger):
			continue
		if not stagger.is_staggered:
			continue
		
		var health = enemy.get_node_or_null("HealthComponent") as HealthComponent
		if not health or health.current_health <= 0.0:
			continue

		var offset = enemy.global_position - player.global_position
		offset.y = 0.0
		var distance = offset.length()

		if distance <= 0.01 or distance > riposte_range:
			continue

		var forward = -player.global_basis.z
		forward.y = 0.0
		if forward.normalized().dot(offset.normalized()) < front_dot_min:
			continue
		if not _has_clear_path(enemy):
			continue
		
		if distance < best_distance:
			best = enemy
			best_distance = distance
	
	return best

func _has_clear_path(enemy: Node3D) -> bool:
	var query = PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP, enemy.global_position + Vector3.UP)
	query.exclude = [player.get_rid()]
	query.collide_with_areas = true

	var result = player.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	
	var collider = result.get("collider") as Node3D
	return collider == enemy or enemy.is_ancestor_of(collider)

func _remove_target(id: int) -> void:
	if not targets.has(id):
		return
	
	var entry: Dictionary = targets[id]
	var enemy = entry["enemy"] as Node3D
	targets.erase(id)

	if is_instance_valid(enemy):
		riposte_window_closed.emit(enemy)
	
	if enemy == target and phase != Phase.RECOVERY:
		_finish()
	elif enemy == target:
		target = null

func _finish() -> void:
	phase = Phase.NONE
	phase_left = 0.0
	lunge_velocity = Vector3.ZERO
	target = null
