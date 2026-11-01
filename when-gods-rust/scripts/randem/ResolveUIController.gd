class_name ResolveUIController
extends Node

@export var follow_speed = 18.0
@export var smoothing_speed = 12.0
@export var screen_offset = 0.8
@export var height_offset = 0.5

@onready var resolveC: ResolveComponent = $"../ResolveComponent"
@onready var upgradeC: UpgradeComponent = $"../UpgradeComponent"
@onready var cameraC: CameraComponent = $"../CameraComponent"

@onready var world_sprite: Sprite3D = $"../ResolveComponent/ResolveSprite"
@onready var world_viewport: SubViewport = $"../ResolveComponent/Resolve"
@onready var world_bar: ProgressBar = $"../ResolveComponent/Resolve/ResolveBar"
@onready var hud_bar: ProgressBar = $"../../CanvasLayer/Control/ResolveBar"
@onready var load_marker: ColorRect = $"../ResolveComponent/Resolve/LoadMarker"

var target_resolve = 0.0
var max_resolve

func _ready() -> void:
	resolveC.resolve_changed.connect(_on_resolve_changed)
	upgradeC.load_changed.connect(_on_load_changed)

	world_bar.max_value = resolveC.maxResolve
	hud_bar.max_value = 100.0
	world_sprite.global_position = _get_world_bar_position()
	world_sprite.render_priority = 1000
	_on_resolve_changed(resolveC.cResolve, resolveC.maxResolve)
	_on_load_changed(upgradeC.get_current_load(), resolveC.maxResolve)
	call_deferred("_assign_viewport_texture")

func _process(delta: float) -> void:
	var weight = 1.0 - exp(-smoothing_speed * delta)
	world_bar.value = lerpf(world_bar.value, target_resolve, weight)

	var hud_target = target_resolve / max_resolve * 100.0
	hud_bar.value = lerpf(hud_bar.value, hud_target, weight)

	var target_position = _get_world_bar_position()
	var follow_weight = 1.0 - exp(-follow_speed * delta)

	world_sprite.global_position = world_sprite.global_position.lerp(target_position, follow_weight)

func _on_resolve_changed(current: float, maximum: float) -> void:
	target_resolve = current
	max_resolve = maxf(maximum, 1.0)
	world_bar.max_value = maximum

func _on_load_changed(current: float, maximum: float) -> void:
	if maximum <= 0.0:
		return
	
	var ratio = clampf(current / maximum, 0.0, 1.0)
	load_marker.anchor_bottom = 1.0 - ratio
	load_marker.anchor_left = 0.0
	load_marker.anchor_right = 1.0
	load_marker.anchor_top = 1.0 - ratio
	load_marker.offset_bottom = 1.5
	load_marker.offset_top = -1.5
	load_marker.offset_right = 0.0
	load_marker.offset_left = 0.0
	
func _assign_viewport_texture() -> void:
	world_sprite.texture = world_viewport.get_texture()

func _get_world_bar_position() -> Vector3:
	var screen_left = -cameraC.cam.global_basis.x
	screen_left.y = 0.0
	screen_left = screen_left.normalized()

	return (resolveC.player.global_position + screen_left * screen_offset + Vector3.UP * height_offset)
