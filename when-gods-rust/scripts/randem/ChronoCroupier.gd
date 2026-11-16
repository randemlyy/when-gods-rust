class_name ChronoCroupier
extends CharacterBody3D

signal activated
signal phase_changed(index: int, phase_name: String)
signal defeated

const MAX_HEALTH = 720
const PHASE_NAMES = ["King of Clubs", "Queen of Spades", "Ace of Diamond", "Jester"]

@export var auto_activate: bool = true

@export var parry_stagger_duration_override: float = 0.9
@export var riposte_range_override: float = 3.6

@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var stateMachine: StateMachine = $StateMachine
@onready var movementC: MovementComponent = $MovementComponent

@onready var model: Node3D = get_node_or_null("ModelPivot") as Node3D

var is_active := false
var is_dead := false
var phase_index := -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemy")
	add_to_group("Boss")
	collision_layer = 3
	collision_mask = 1

	movementC.body = self
	staggerC.stagger_threshold = 0.5
	healthC.max_health = MAX_HEALTH
	healthC.start()
	healthC.died.connect(_on_died)
	staggerC.stagger_started.connect(_on_stagger_started)

	if auto_activate:
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(self):
			activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	healthC.update(delta)

func activate() -> void:
	if is_active or is_dead:
		return
	
	is_active = true
	_set_phase(0)
	stateMachine.change_state("kingofclubs")
	activated.emit()

func _set_phase(index: int) -> void:
	phase_index = index
	phase_changed.emit(index, PHASE_NAMES[index])

func _on_stagger_started() -> void:
	if is_dead:
		return
	
	if stateMachine.cState and stateMachine.cState.has_method("interrupt"):
		stateMachine.cState.call("interrupt")

func _on_died() -> void:
	if is_dead:
		return
	
	is_dead = true
	is_active = false
	stateMachine.set_process(false)
	stateMachine.set_physics_process(false)
	set_physics_process(false)
	defeated.emit()

	if is_instance_valid(model):
		var t = create_tween()
		t.tween_property(model, "scale", Vector3(0.05, 0.05, 0.05), 1.2)
		t.tween_interval(0.5)
		t.tween_callback(queue_free)
	else:
		queue_free()
	