extends Area3D

@export_file("*.tscn") var target_scene: String = "res://scenes/randemlyy/BossArena.tscn"
@export var fade_time: float = 0.9
@export var fog_color: Color = Color(0.78, 0.82, 0.86, 1.0)

var _used = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _used or not body.is_in_group("Player"):
		return
	
	if target_scene.is_empty():
		return
	
	_used = true
	_fade_and_go()

func _fade_and_go() -> void:
	var layer = CanvasLayer.new()
	layer.layer = 128
	add_child(layer)

	var rect = ColorRect.new()
	rect.color = Color(fog_color.r, fog_color.g, fog_color.b, 0.0)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)

	var tween = create_tween()
	tween.tween_property(rect, "color:a", 1.0, fade_time)
	await tween.finished

	get_tree().change_scene_to_file(target_scene)

