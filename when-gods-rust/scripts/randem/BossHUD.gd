extends CanvasLayer

@export var boss_title: String = "THE CHRONO CROUPIER"
@export var boss_path: NodePath = ^".."
@export var bar_tween_time: float = 0.25

@onready var boss: ChronoCroupier = get_node(boss_path) as ChronoCroupier
@onready var health: HealthComponent = boss.get_node("HealthComponent")
@onready var root: Control = $Root
@onready var intro_name: Label = $Root/IntroName
@onready var phase_name: Label = $Root/PhaseName
@onready var bar_name: Label = $Root/BarBox/BarName
@onready var bar: ProgressBar = $Root/BarBox/Bar

var _bar_tween: Tween
var _phase_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer = 10
	root.modulate.a = 0.0
	phase_name.modulate.a = 0.0

	intro_name.text = boss_title
	bar_name.text = boss_title
	bar.max_value = health.max_health
	bar.value = health.max_health

	health.health_changed.connect(_on_health_changed)
	boss.activated.connect(_on_activated)
	boss.phase_changed.connect(_on_phase_changed)
	boss.defeated.connect(_on_defeated)

	var world_bar = boss.get_node_or_null("HealthComponent/Sprite3D")
	if world_bar:
		world_bar.visible = false

func _on_health_changed(current: int, maximum: int) -> void:
	bar.max_value = maximum
	
	if _bar_tween and _bar_tween.is_valid():
		_bar_tween.kill()

	_bar_tween = create_tween()
	_bar_tween.tween_property(bar, "value", float(current), bar_tween_time)

func _on_activated() -> void:
	var show_tween = create_tween()
	show_tween.tween_property(root, "modulate:a", 1.0, 0.4)

	intro_name.modulate.a = 0.
	var intro = create_tween()
	intro.tween_property(intro_name, "modulate:a", 1.0, 0.4)
	intro.tween_interval(1.5)
	intro.tween_property(intro_name, "modulate:a", 0.0, 0.7)

func _on_phase_changed(index: int, display_name: String) -> void:
	if index <= 0:
		return
	
	bar_name.text = "%s - %s" % [boss_title, display_name.to_upper()]

	if _phase_tween and _phase_tween.is_valid():
		_phase_tween.kill()
	
	phase_name.text = display_name.to_upper()
	phase_name.modulate.a = 0.0

	_phase_tween = create_tween()
	_phase_tween.tween_property(phase_name, "modulate:a", 1.0, 0.35)
	_phase_tween.tween_interval(1.3)
	_phase_tween.tween_property(phase_name, "modulate:a", 0.0, 0.6)

func _on_defeated() -> void:
	var hide_tween = create_tween()
	hide_tween.tween_property(root, "modulate:a", 0.0, 0.6)
