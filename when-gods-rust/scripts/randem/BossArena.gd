extends Node3D

@export_file("*.tscn") var victory_scene: String = "res://scenes/icyfire/finishscreen.tscn"
@export var victory_delay: float = 1.8
@export var fade_time: float = 0.9
@export var fog_color: Color = Color(0.78, 0.82, 0.86, 1.0)

@onready var boss: ChronoCroupier = $ChronoCroupier

var _won = false

func _fade_in() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 128
	add_child(layer)

	var rect := ColorRect.new()
	rect.color = Color(fog_color.r, fog_color.g, fog_color.b, 1.0)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)

	var tween := create_tween()
	tween.tween_property(rect, "color:a", 0.0, fade_time)
	await tween.finished
	layer.queue_free()


func _ready() -> void:
	boss.defeated.connect(_on_boss_defeated)
	await _fade_in()
	boss.activate()

func _on_boss_defeated() -> void:
	if _won:
		return
	_won = true

	await get_tree().create_timer(victory_delay).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(victory_scene)