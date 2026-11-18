extends CanvasLayer

@export var boss_title: String = "THE CHRONO CROUPIER"
@export var boss_path: NodePath = ^".."

@onready var boss: ChronoCroupier = get_node(boss_path) as ChronoCroupier
@onready var health: HealthComponent = boss.get_node("HealthComponent")
@onready var root: Control = $Root
@onready var intro_name: Label = $Root/IntroName
@onready var bar_name: Label = $Root/BarBox/BarName
@onready var bar: ProgressBar = $Root/BarBox/Bar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer = 10
	root.modulate.a = 0.0

	intro_name.text = boss_title
	bar_name.text = boss_title
	bar.max_value = health.max_health
	bar.value = health.max_health

	health.health_changed.connect(_on_health_changed)
	boss.activated.connect(_on_activated)
	boss.defeated.connect(_on_defeated)

	var world_bar = boss.get_node_or_null("HealthComponent/Sprite3D")
	if world_bar:
		world_bar.visible = false

func _on_health_changed(current: int, maximum: int) -> void:
	bar.max_value = maximum
	bar.value = current

func _on_activated() -> void:
	var show_tween = create_tween()
	show_tween.tween_property(root, "modulate:a", 1.0, 0.4)

	intro_name.modulate.a = 0.
	var intro = create_tween()
	intro.tween_property(intro_name, "modulate:a", 1.0, 0.4)
	intro.tween_interval(1.5)
	intro.tween_property(intro_name, "modulate:a", 0.0, 0.7)

func _on_defeated() -> void:
	var hide_tween = create_tween()
	hide_tween.tween_property(root, "modulate:a", 0.0, 0.6)
