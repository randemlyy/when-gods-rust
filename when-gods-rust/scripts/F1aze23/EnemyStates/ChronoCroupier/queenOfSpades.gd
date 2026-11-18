extends EnemyStates

const SPADE = Color(0.38, 0.88, 1.0)
const RED = Color(1.0, 0.18, 0.18)

@export var fan_cards = 5
@export var fan_spread = 45.0
@export var card_speed = 13.0
@export var card_life = 1.4
@export var blink_cd = 4.0
@export var rain_cd = 6.0

var _attacks = {
	"fan": {"id": "fan", "windup": 0.55, "active": 0.10, "recovery": 0.65, "cooldown": 1.0, "damage": 9, "stagger": 0.5, "push": 2.0, "length": 10.0, "width": 5.5, "color": SPADE},
	"sweep": {"id": "sweep", "windup": 0.42, "active": 0.16, "recovery": 0.55, "cooldown": 1.1, "damage": 13, "stagger": 0.8, "push": 6.0, "length": 3.0, "width": 6.0, "color": SPADE},
	"rain":  {"id": "rain", "windup": 0.95, "active": 0.12, "recovery": 0.80, "cooldown": 1.6, "damage": 20, "stagger": 1.0, "push": 4.0, "unblockable": true},
	"blink": {"id": "blink", "windup": 0.14, "active": 0.10, "recovery": 0.30, "cooldown": 0.4},
}

var _fan_dir = Vector3.ZERO
var _blink_at = 0.0
var _rain_at = 0.0
var _rain_pts : Array[Vector3] =[]

func enter() -> void:
	super.enter()
	_fan_dir = Vector3.ZERO
	_blink_at = 0.0
	_rain_at = 0.0
	_rain_pts.clear()

func _idle_move(_delta: float, to_player: Vector3, distance: float) -> Vector3:
	if to_player.length_squared() < 0.001:
		return Vector3.ZERO
	
	if distance < 5.0:
		return -to_player.normalized()
	
	if distance > 9.5:
		return to_player.normalized()
	
	return Vector3.ZERO

func _pick_attack(_distance: float) -> Dictionary:
	var now = _now()
	if _distance < 3.2 and now >= _blink_at:
		return _attacks["blink"]

	if now >= _rain_at and _distance > 5.5:
		return _attacks["rain"]
	
	if _distance > 4.8:
		return _attacks["sweep"]

	return _attacks["fan"]

func _on_attack_start(_attack: Dictionary) -> void:
	match _attack["id"]:
		"rain":
			_rain_marks(_attack)
		"fan":
			_fan_dir = _dir_to_player()
			_spawn_telegraph_line(_attack["length"], _attack["width"], _attack["color"], _attack["windup"])
		"sweep":
			_spawn_telegraph_line(_attack["length"], _attack["width"], _attack["color"], _attack["windup"])
		"blink":
			_spawn_telegraph_circle(1.2, SPADE, 0.25)

func _on_active_start(_attack: Dictionary) -> void:
	match _attack["id"]:
		"fan":
			_fire_fan(_attack)
		"sweep":
			_hit_area(wide_hitbox, _attack)
		"rain":
			_detonate_rain(_attack)
		"blink":
			_blink()

func _on_active_tick(_attack: Dictionary) -> void:
	if _attack["id"] == "sweep":
		_hit_area(wide_hitbox, _attack)

func _on_attack_end(_attack: Dictionary) -> void:
	_rain_pts.clear()
	_fan_dir = Vector3.ZERO

func _fire_fan(_attack: Dictionary) -> void:
	var base = _fan_dir if _fan_dir != Vector3.ZERO else _dir_to_player()
	if base == Vector3.ZERO:
		return
	
	if fan_cards <= 1:
		_card(base, _attack)
		return
	
	var total = deg_to_rad(fan_spread)
	var step = total / float(fan_cards - 1)
	for i in fan_cards:
		_card(base.rotated(Vector3.UP, -total * 0.5 + step * i), _attack)

func _card(dir: Vector3, _attack: Dictionary) -> void:
	var pos = body.global_position + Vector3.UP * 2.0 + dir * 1.5
	_projectile(pos, dir, Vector3(0.8, 1.0, 0.2), SPADE, card_speed, card_life, _attack)

func _rain_marks(_attack: Dictionary) -> void:
	_rain_pts.clear()
	var dir = _dir_to_player()
	if dir == Vector3.ZERO:
		dir = -body.global_basis.z
		dir.y = 0.0
		dir = dir.normalized()
	
	var right = dir.cross(Vector3.UP)
	right = right.normalized() if right.length_squared() > 0.001 else Vector3.RIGHT
	var offsets: Array[Vector3] = [Vector3.ZERO, right * 2.6, -right * 2.6]
	for off in offsets:
		var p: Vector3 = player.global_position + off
		_rain_pts.append(p)
		_spawn_telegraph_circle(1.8, RED, _attack["windup"], p - body.global_position)

func _detonate_rain(_attack: Dictionary) -> void:
	_rain_at = _now() + rain_cd

	for p in _rain_pts:
		_pillar(p, RED, 5.0)
		var d = player.global_position - p
		d.y = 0.0
		if d.length() <= 2.1:
			_hit_target(player, _attack)

func _blink() -> void:
	_blink_at = _now() + blink_cd
	var away = body.global_position - player.global_position
	away.y = 0.0

	if away.length_squared() < 0.001:
		away = -player.global_basis.z
	away = away.normalized()

	var side = away.cross(Vector3.UP)
	if side.length_squared() <= 0.001:
		side = Vector3.RIGHT
	
	var dir = (away + side.normalized() * randf_range(-0.9, 0.9)).normalized()
	var target = player.global_position + dir * randf_range(7.5, 9.5)
	target.y = body.global_position.y
	var q = PhysicsRayQueryParameters3D.create(body.global_position + Vector3.UP * 2.0, target + Vector3.UP * 2.0)
	q.exclude = [body.get_rid()]

	var hit = body.get_world_3d().direct_space_state.intersect_ray(q)
	if not hit.is_empty():
		var p: Vector3 = hit["position"]
		target.x = p.x
		target.z = p.z
	
	body.global_position = target
	_face_instant()

func _dir_to_player() -> Vector3:
	var d = player.global_position - body.global_position
	d.y = 0.0

	return d.normalized() if d.length_squared() > 0.001 else Vector3.ZERO

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0

	


