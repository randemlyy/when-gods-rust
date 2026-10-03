extends CharacterBody3D

@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var attackC: AttackComponent = $AttackComponent
@onready var cameraC: CameraComponent = $CameraComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var attack_meter: ProgressBar = $CanvasLayer/AttackMeter
@onready var crit_marker: ColorRect = $CanvasLayer/AttackMeter/CritMarker
@onready var attack_hitbox: Area3D = $Area3D
@export var mouse_sens:float = 0.002
@export var stagger_dura: float = 0.8

var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	attackC.attack_started.connect(_on_attack_started)

func _process(delta: float) -> void:
	inputC.update(delta)
	cameraC.update(self)
	var point_from_player = global_position + Vector3.LEFT
	attack_meter.position = cameraC.cam.unproject_position(point_from_player) - attack_meter.size / 3
	attack_meter.visible = attackC.is_attacking and attackC.state != AttackComponent.State.RECOVERY
	var duration = attackC.attack_durations[attackC.current_attack]
	if duration > 0.0:
		attack_meter.value = attackC.attack_time / duration * 100.0
	var index = attackC.current_attack
	var start_ratio = attackC.crit_window_starts[index] / duration
	var end_ratio = attackC.crit_window_ends[index] / duration
	
	crit_marker.position = Vector2(start_ratio * attack_meter.size.x, 0)
	crit_marker.size = Vector2(
		(end_ratio - start_ratio) * attack_meter.size.x,
		attack_meter.size.y
	)
	crit_marker.visible = end_ratio > start_ratio

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if staggerC.is_staggered:
		attackC.cancel_attack()
		velocity.x = 0
		velocity.z = 0 
		move_and_slide()
		return
	
	# actual movement direction, taking into account everything
	attackC.physics_update(delta, inputC.attack)
	var should_hit = (attackC.state == AttackComponent.State.ATTACKING or attackC.state == AttackComponent.State.COMBO_WINDOW)
	
	if attack_hitbox.monitoring != should_hit:
		attack_hitbox.set_deferred("monitoring", should_hit)
	
	if not attackC.is_attacking:
		movementC.physics_update(delta, Vector3(inputC.dir.x, 0, inputC.dir.y), self)
	move_and_slide()

func take_hit(damage: int, hit_stagger_duration: float = 0.8) -> void:
	healthC.take_damage(damage)
	if attackC.is_winding_up:
		attackC.cancel_attack()
		attack_hitbox.set_deferred("monitoring", false)
		staggerC.apply_stagger(hit_stagger_duration)

func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	if not body.has_method("take_hit"):
		return
	if body in bodies_hit_this_swing:
		print("Repeat hit blocked: ", body.name)
		return
	
	bodies_hit_this_swing.append(body)
	
	var damage = 10
	if attackC.is_current_crit:
		damage += 5
	body.call("take_hit", damage)

func _on_attack_started() -> void:
	print("New swing. Clearing ", bodies_hit_this_swing.size(), " recorded hits.")
	bodies_hit_this_swing.clear()
