class_name EnemyStates
extends state

enum Phase { IDLE, WINDUP, ACTIVE, RECOVERY }

@export_group("Wiring")
@export var body: CharacterBody3D
@export var movementC: MovementComponent
@export var front_hitbox: Area3D
@export var wide_hitbox: Area3D

@export_group("Movement")
@export var move_speed = 3.2
@export var turn_speed = 2.0
@export var stop_distance = 2.2
@export var decision_time = 0.9

var player: Node3D
var phase = Phase.IDLE
var phase_left = 0.0
var current: Dictionary = {}
var move_dir = Vector3.ZERO

var _hit_ids: Dictionary = {}
var _telegraphs: Array[Node3D] = []

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player") as Node3D
	if movementC:
		movementC.speed = move_speed
		movementC.cancel_attack_lunge()

	phase = Phase.IDLE
	phase_left = decision_time
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()
	_clear_telegraphs()
	_face_instant()

func exit() -> void:
	if not current.is_empty():
		_on_attack_end(current)
	move_dir = Vector3.ZERO
	_clear_telegraphs()
	if movementC:
		movementC.cancel_attack_lunge()
	_hit_ids.clear()

func update(delta: float) -> void:
	if not is_instance_valid(body) or not body.is_inside_tree():
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as Node3D
		if not is_instance_valid(player):
			return

	var to_player = player.global_position - body.global_position
	to_player.y = 0.0
	var distance = to_player.length()

	match phase:
		Phase.IDLE:
			move_dir = _idle_move(delta, to_player, distance)
			if move_dir.length_squared() > 0.001:
				_face_towards(move_dir, delta)
			phase_left -= delta
			if phase_left <= 0.0:
				var attack = _pick_attack(distance)
				if attack.is_empty():
					phase_left = 0.25
				else:
					_begin(attack)
		Phase.WINDUP:
			phase_left -= delta
			if phase_left <= 0.0:
				_begin_active()
		Phase.ACTIVE:
			_on_active_tick(current)
			if phase != Phase.ACTIVE:
				return
			phase_left -= delta
			if phase_left <= 0.0:
				_begin_recovery()
		Phase.RECOVERY:
			phase_left -= delta
			if phase_left <= 0.0:
				_end_attack()

func physics_update(delta: float) -> void:
	if not is_instance_valid(body) or not body.is_inside_tree():
		return
	if movementC:
		var dir = move_dir if phase == Phase.IDLE else Vector3.ZERO
		movementC.physics_update(delta, dir, body, false)
	body.move_and_slide()

func interrupt() -> void:
	if phase == Phase.IDLE:
		return
	_clear_telegraphs()
	if movementC:
		movementC.cancel_attack_lunge()
	_on_attack_end(current)
	_on_interrupt()
	phase = Phase.IDLE
	phase_left = maxf(decision_time, 0.6)
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()

# --------- flow ----------

func _begin(attack: Dictionary) -> void:
	current = attack
	_hit_ids.clear()
	phase = Phase.WINDUP
	phase_left = maxf(float(attack.get("windup", 0.4)), 0.01)
	move_dir = Vector3.ZERO
	if movementC:
		movementC.cancel_attack_lunge()
	_face_instant()
	_on_attack_start(attack)

func _begin_active() -> void:
	_clear_telegraphs()
	phase = Phase.ACTIVE
	phase_left = maxf(float(current.get("active", 0.15)), 0.01)
	_hit_ids.clear()

	var lunge := float(current.get("lunge", 0.0))
	if lunge > 0.0 and movementC:
		var lunge_time := maxf(float(current.get("lunge_time", phase_left)), 0.05)
		movementC.start_attack_lunge(lunge, lunge_time)

	_on_active_start(current)

func _begin_recovery() -> void:
	phase = Phase.RECOVERY
	phase_left = maxf(float(current.get("recovery", 0.5)), 0.01)

func _end_attack() -> void:
	if not current.is_empty():
		_on_attack_end(current)
	phase = Phase.IDLE
	phase_left = maxf(float(current.get("cooldown", decision_time)), 0.05)
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()

# ------- hooks ---------

func _pick_attack(_distance: float) -> Dictionary: return {}
func _idle_move(_delta: float, to_player: Vector3, distance: float) -> Vector3:
	return to_player.normalized() if distance > stop_distance and to_player.length_squared() > 0.001 else Vector3.ZERO
func _on_attack_start(_attack: Dictionary) -> void: pass
func _on_active_start(_attack: Dictionary) -> void: pass
func _on_active_tick(_attack: Dictionary) -> void: pass
func _on_attack_end(_attack: Dictionary) -> void: pass
func _on_hit(_attack: Dictionary, _target: Node3D) -> void: pass
func _on_interrupt() -> void: pass

# ------- facing ------

func _face_instant() -> void:
	if not is_instance_valid(body) or not is_instance_valid(player):
		return
	var dir := player.global_position - body.global_position
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		body.rotation.y = atan2(-dir.x, -dir.z)

func _face_towards(dir: Vector3, delta: float) -> void:
	if not is_instance_valid(body):
		return
	dir.y = 0.0
	if dir.length_squared() < 0.001:
		return
	var target_yaw := atan2(-dir.x, -dir.z)
	body.rotation.y = rotate_toward(body.rotation.y, target_yaw, turn_speed * delta)

# ------- telegraphs --------

func _spawn_telegraph_line(length: float, width: float, color: Color, duration: float) -> BossTelegraph:
	if not is_instance_valid(body):
		return null
	var t := BossTelegraph.new()
	body.add_child(t)
	t.position = Vector3(0.0, 0.02, 0.0)
	t.setup_line(length, width, color, duration)
	_telegraphs.append(t)
	return t

func _spawn_telegraph_circle(radius: float, color: Color, duration: float, offset: Vector3 = Vector3.ZERO) -> BossTelegraph:
	if not is_instance_valid(body):
		return null
	var t := BossTelegraph.new()
	body.add_child(t)
	t.global_position = body.global_position + offset + Vector3.UP * 0.02
	t.setup_circle(radius, color, duration)
	_telegraphs.append(t)
	return t

func _clear_telegraphs() -> void:
	for t in _telegraphs:
		if is_instance_valid(t):
			t.queue_free()
	_telegraphs.clear()

# ------- damage --------

func _hit_area(area: Area3D, attack: Dictionary) -> int:
	if not is_instance_valid(area):
		return 0
	var hits := 0
	for target in area.get_overlapping_bodies():
		if _hit_target(target, attack):
			hits += 1
	return hits

func _hit_target(target: Node3D, attack: Dictionary) -> bool:
	if not is_instance_valid(target) or not target.is_in_group("Player"):
		return false
	if not target.has_method("take_hit"):
		return false

	var id := target.get_instance_id()
	if _hit_ids.has(id):
		return false
	_hit_ids[id] = true

	var dir := Vector3.ZERO
	if is_instance_valid(body):
		dir = target.global_position - body.global_position
		dir.y = 0.0
		if dir.length_squared() > 0.001:
			dir = dir.normalized()

	target.call("take_hit",
		int(attack.get("damage", 10)),
		float(attack.get("stagger", 0.8)),
		dir * float(attack.get("push", 0.0)),
		body, null, bool(attack.get("unblockable", false)))

	_on_hit(attack, target)
	return true

# --- reusable VFX ---

func _fx_host() -> Node:
	var host: Node = get_tree().current_scene
	if host == null and is_instance_valid(body):
		host = body.get_parent()
	return host

func _projectile(pos: Vector3, dir: Vector3, size: Vector3, color: Color, speed: float, life: float, attack: Dictionary) -> void:
	var host := _fx_host()
	if host == null:
		return

	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	area.add_child(shape)

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.95, 1.0)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.8
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	area.add_child(mesh)

	host.add_child(area)
	area.global_position = pos
	area.look_at(pos + dir, Vector3.UP)

	area.body_entered.connect(func(target: Node3D) -> void:
		if not is_instance_valid(target) or not is_instance_valid(body):
			area.queue_free()
			return
		if _hit_target(target, attack):
			area.queue_free()
	)

	var tween := area.create_tween()
	tween.tween_property(area, "global_position", pos + dir * speed * life, life)
	tween.tween_callback(area.queue_free)

func _pillar(pos: Vector3, color: Color, height: float) -> void:
	var host := _fx_host()
	if host == null:
		return

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.35, height, 0.35)
	mesh.mesh = box_mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, 0.65)
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(mesh)
	mesh.global_position = pos + Vector3.UP * height * 0.5
	mesh.scale = Vector3(0.2, 1.0, 0.2)

	var tween := mesh.create_tween()
	tween.tween_property(mesh, "scale", Vector3.ONE, 0.12)
	tween.tween_interval(0.16)
	var fade := func(alpha: float) -> void:
		mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	tween.tween_method(fade, 0.65, 0.0, 0.22)
	tween.tween_callback(mesh.queue_free)
