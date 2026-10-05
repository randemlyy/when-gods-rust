extends Control


@onready var label: Label = $Label
@onready var label_2: Label = $Label2


func _ready() -> void:
	label.modulate.a = 1.0
	label_2.modulate.a = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(2).timeout
	print("lerping")
	label.modulate.a = lerp(label.modulate.a, 0.0, 1.0 * delta)
	label_2.modulate.a = lerp(label_2.modulate.a, 0.0, 1.0 * delta)
	
	if label.modulate.a <= 0.1:
		queue_free()
	
	pass
