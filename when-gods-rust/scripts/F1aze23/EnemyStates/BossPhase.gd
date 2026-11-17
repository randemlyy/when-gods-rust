class_name EnemyStates
extends state

enum Phase {
	IDLE,
	WINDUP,
	ACTIVE,
	RECOVERY
}


@export_group("Wiring")
@export var body: CharacterBody3D
@export var nav: NavigationAgent3D
@export var movementC: MovementComponent
@export var model: Node3D
@export var front_hitbox: Area3D
@export var wide_hitbox: Area3D
@export var shockwave: Area3D

@export_group("Movement")
@export var move_speed := 3.2
@export var turn_speed := 2.0
@export var stop_distance := 2.2
@export var decision_time := 0.9

var player: Node3D
var phase := Phase.IDLE
var phase_left := 0.0
var current: Dictionary = {}
var move_dir := Vector3.ZERO
var _hit_ids: Dictionary = {}
var _model_base := Vector3.ZERO
var _last_attack_id := ""
var _telegraphs: Array[Node3D] = []

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player") as Node3D
	if is_instance_valid(nav) and is_instance_valid(body):
		nav.set_navigation_map(body.get_world_3d().navigation_map)
	if is_instance_valid(movementC):
		movementC.speed = move_speed
	if is_instance_valid(model):
		_model_base = model.position
	
	phase = Phase.IDLE
	phase_left = decision_time
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()
	_kill_telegraph()
	_kill_tween()
	if is_instance_valid(body) and is_instance_valid(player):
		_face_instant()

func exit() -> void:
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
			if move_dir.length_squared() < 0.0001:
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
				_active()
			
		Phase.ACTIVE:
			_tick_active(current)
			phase_left -= delta
			if phase_left <= 0.0:
				_recover()
			
		Phase.RECOVERY:
			phase_left -= delta
			if phase_left <= 0.0:
				start_idle()

func physics_update(delta: float) -> void:
	if not is_instance_valid(body) or not body.is_inside_tree():
		return
	
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
	_reset_model()

	phase = Phase.IDLE
	phase_left = maxf(decision_time, 0.6)
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()

# --------- flow ----------

func _begin(attack: Dictionary) -> void:
	current = attack
	_hit_ids.clear()
	_last_attack_id = str(attack.get("id", ""))
	phase = Phase.WINDUP
	phase_left = maxf(float(attack.get("windup", 0.4)), 0.01)
	move_dir = Vector3.ZERO

	if movementC:
		movementC.cancel_attack_lunge()
	
	_face_instant()
	_on_attack_start(attack)

func _active() -> void:
	_clear_telegraphs()
	phase = Phase.ACTIVE
	phase_left = maxf(float(current.get("active", 0.15)), 0.01)
	_hit_ids.clear()
	var lunge = float(current.get("lunge", 0.0))
	if lunge > 0.0 and movementC:
		movementC.start_attack_lunge(lunge, maxf(float(current.get("lunge_time", phase_left)), 0.05)
	
	_on_active_start(current)

func _recover() -> void:
	phase = Phase.RECOVERY
	phase_left = maxf(float(current.get("recovery", 0.5)), 0.01)
	_on_recovery_start(current)

func start_idle() -> void:
	if not current.is_empty():
		_on_attack_end(current)
	
	_reset_model()
	phase = Phase.IDLE
	phase_left = maxf(float(current.get("cooldown", decision_time)), 0.05)
	current = {}
	move_dir = Vector3.ZERO
	_hit_ids.clear()

# ------- hooks ---------

func _pick_attack(_distance: float) -> Dictionary: return {}

func _idle_move(_delta: float, to_player: Vector3, distance: float) -> Vector3:
	return to_player.normalized() if distance > stop_distance and to_player.length_squared() > 0.001 else Vector3.ZERO

func _on_attack_start(_a: Dictionary) -> void: pass
func _on_active_start(_a: Dictionary) -> void: pass
func _on_active_tick(_a: Dictionary) -> void: pass
func _on_recovery_start(_a: Dictionary) -> void: pass
func _on_attack_end(_a: Dictionary) -> void: pass
func _on_hit(_a: Dictionary, _t: Node3D) -> void: pass
func _tick_active(a: Dictionary) -> void: _on_active_tick(a)
func _end_attack_id() -> void: pass
func _kill_tween() -> void: pass


# ------- telegraphs --------

func _spawn_telegraph_line(length: float, width: float, color: Color, duration: float) -> BossTelegraph:
	if !body:
		return null
	
	var t = BossTelegraph.new()
	body.add_child(t)
	t.position = Vector3(0, 0.02, 0)
	t.setup_line(length, width, color, duration)
	_telegraphs.append(t)
	return t

func _spawn_telegraph_circle(radius: float, color: Color, duration: float, offset := Vector3.ZERO) -> BossTelegraph:
	if !body:
		return null
	
	var t = BossTelegraph.new()
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
	if not area:
		return 0
	
	var n = 0

	for t in area.get_overlapping_bodies():
		if _hit_target(t, attack):
			n += 1
	
	return n

func _hit_target(target: Node3D, attack: Dictionary) -> bool:
	if not is_instance_valid(target) or not target.is_in_group("Player"):
		return false
	
	var id = target.get_instance_id()
	if _hit_ids.has(id):
		return false
	
	_hit_ids[id] = true

	var d = Vector3.ZERO
	if body:
		d = target.global_position - body.global_position
		d.y = 0.0
		if d.length_squared() > 0.001:
			d = d.normalized()
	
	target.call("take_hit", 
		int(attack.get("damage", 10)),
		float(attack.get("stagger", 0.8)),
		d * float(attack.get("push", 0.0)),
		body, null, bool(attack.get("unblockable", false)))
	
	_on_hit(attack, target)
	return true

func _reset_model() -> void:
	if model:
		model.position = _model_base

# --- reusable VFX ---

func _fx_host() -> Node:
	var h: Node = get_tree().current_scene
	if h == null and body: 
		h = body.get_parent()
	return h

func _projectile(pos: Vector3, dir: Vector3, size: Vector3, color: Color, speed: float, life: float, atk: Dictionary) -> void:
	var host := _fx_host()
	if host == null: return
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	area.add_child(cs)
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.95, 1.0)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.8
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	area.add_child(mi)
	host.add_child(area)
	area.global_position = pos
	area.look_at(pos + dir, Vector3.UP)
	area.body_entered.connect(func(t: Node3D) -> void:
		if not is_instance_valid(t) or not is_instance_valid(body):
			area.queue_free()
			return
		if _hit_target(t, atk): area.queue_free()
	)
	var tw := area.create_tween()
	tw.tween_property(area, "global_position", pos + dir * speed * life, life)
	tw.tween_callback(area.queue_free)

func _pillar(pos: Vector3, color: Color, height: float) -> void:
	var host := _fx_host()
	if host == null: return
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.35, height, 0.35)
	mi.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, 0.65)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	host.add_child(mi)
	mi.global_position = pos + Vector3.UP * height * 0.5
	mi.scale = Vector3(0.2, 1.0, 0.2)
	var tw := mi.create_tween()
	tw.tween_property(mi, "scale", Vector3.ONE, 0.12)
	tw.tween_interval(0.16)
	var fade := func(a: float) -> void: mat.albedo_color = Color(color.r, color.g, color.b, a)
	tw.tween_method(fade, 0.65, 0.0, 0.22)
	tw.tween_callback(mi.queue_free)