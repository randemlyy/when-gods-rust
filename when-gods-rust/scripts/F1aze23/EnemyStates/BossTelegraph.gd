class_name BossTelegraph
extends Node3D

var _mesh: MeshInstance3D
var _mat: StandardMaterial3D
var _duration:= 1.0
var _elapsed:= 0.0
var _from_scale:= Vector3.ONE
var _to_scale:= Vector3.ONE
var _base_alpha:= 0.42
var _done:= false

func setup_circle(radius: float, color: Color, duration: float) -> void:
	_build_cylinder(radius)
	_from_scale = Vector3(0.08, 1.0, 0.08)
	_to_scale = Vector3.ONE
	_apply(color, duration)

func setup_line(length: float, width: float, color: Color, duration: float) -> void:
	_build_box(length, width)
	_from_scale = Vector3(0.6, 1.0, 0.05)
	_to_scale = Vector3.ONE
	_apply(color, duration)

func _apply(color: Color, duration: float) -> void:
	_duration = maxf(duration, 0.05)
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat.albedo_color = Color(color.r, color.g, color.b, _base_alpha)
	_mat.no_depth_test = false
	_mesh.material_override = _mat
	scale = _from_scale

func _build_cylinder(radius: float) -> void:
	var m = CylinderMesh.new()
	m.top_radius = radius
	m.bottom_radius = radius
	m.height = 0.02
	m.radial_segments = 48
	_mesh = MeshInstance3D.new()
	_mesh.mesh = m
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh.position.y = 0.01
	add_child(_mesh)

func _build_box(length: float, width: float) -> void:
	var m = BoxMesh.new()
	m.size = Vector3(width, 0.02, length)
	_mesh = MeshInstance3D.new()
	_mesh.mesh = m
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh.position = Vector3(0.0, 0.01, -length * 0.5)
	add_child(_mesh)

func _process(delta: float) -> void:
	if _done or _mat == null:
		return
	
	_elapsed += delta
	var t = clampf(_elapsed / _duration, 0.0, 1.0)
	scale = _from_scale.lerp(_to_scale, ease(t, 0.35))
	var c = _mat.albedo_color
	c.a = _base_alpha * (0.75 + 0.25 * sin(_elapsed * 22.0))
	_mat.albedo_color = c
	if t >= 1.0:
		_done = true
		c.a = 0.9
		_mat.albedo_color = c
		scale = _to_scale
