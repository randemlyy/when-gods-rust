extends EnemyStates

## M1/M2 - King of Clubs: heavy, parryable, ground slam pressure.

const CLUB := Color(0.5, 0.9, 0.35)
const RED := Color(1.0, 0.18, 0.18)

@export var full_kit := true
@export var shockwave: Area3D
@export var quake_cd := 4.0

var _attacks := {
	"slam": {
		"id": "slam", "windup": 0.62, "active": 0.16, "recovery": 0.75, "cooldown": 1.3,
		"damage": 18, "stagger": 0.9, "push": 5.0,
		"box": "front", "length": 4.0, "width": 3.0,
	},
	"sweep": {
		"id": "sweep", "windup": 0.48, "active": 0.18, "recovery": 0.55, "cooldown": 1.0,
		"damage": 14, "stagger": 0.7, "push": 7.0,
		"box": "wide", "length": 3.0, "width": 6.0,
	},
	"charge": {
		"id": "charge", "windup": 0.55, "active": 0.26, "recovery": 0.65, "cooldown": 1.4,
		"damage": 16, "stagger": 0.8, "push": 6.0,
		"lunge": 7.0, "lunge_time": 0.25,
		"box": "front", "length": 7.0, "width": 3.0,
	},
	"quake": {
		"id": "quake", "windup": 0.85, "active": 0.18, "recovery": 1.0, "cooldown": 2.0,
		"damage": 22, "stagger": 1.0, "push": 5.0, "unblockable": true,
	},
}

var _quake_at := 0.0

func enter() -> void:
	super.enter()
	_quake_at = 0.0
	if shockwave:
		shockwave.visible = false

func _pick_attack(distance: float) -> Dictionary:
	if not full_kit:
		return _attacks["slam"]
	if distance > 5.5:
		return _attacks["charge"]
	if Time.get_ticks_msec() / 1000.0 >= _quake_at and distance < 4.2:
		return _attacks["quake"]
	return _attacks["sweep"] if randf() < 0.45 else _attacks["slam"]

func _on_attack_start(attack: Dictionary) -> void:
	if attack["id"] == "quake":
		_spawn_telegraph_circle(_quake_radius(), RED, attack["windup"])
	else:
		_spawn_telegraph_line(attack["length"], attack["width"], CLUB, attack["windup"])

func _on_active_start(attack: Dictionary) -> void:
	if attack["id"] == "quake":
		_quake_at = Time.get_ticks_msec() / 1000.0 + quake_cd
		_show_quake()
		_hit_area(shockwave, attack)
	else:
		_hit_box(attack)

func _on_active_tick(attack: Dictionary) -> void:
	if attack["id"] == "quake":
		_hit_area(shockwave, attack)
	else:
		_hit_box(attack)

func _on_attack_end(_attack: Dictionary) -> void:
	if shockwave:
		shockwave.visible = false

func _hit_box(attack: Dictionary) -> void:
	if attack["box"] == "wide":
		_hit_area(wide_hitbox, attack)
	else:
		_hit_area(front_hitbox, attack)

func _show_quake() -> void:
	if not shockwave:
		return
	shockwave.global_position = body.global_position + Vector3.UP * 0.05
	shockwave.visible = true

func _quake_radius() -> float:
	if shockwave:
		for child in shockwave.get_children():
			var cs := child as CollisionShape3D
			if cs and cs.shape is CylinderShape3D:
				return (cs.shape as CylinderShape3D).radius
	return 4.5
