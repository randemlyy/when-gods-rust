class_name AttackComponent
extends Node

@onready var inventoryC: InventoryComponent = $"../InventoryComponent"
@onready var modifierC: ModifierComponent = $"../ModifierComponent"
@onready var animC: AnimationComponent = $"../AnimationComponent"
@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var attack_cooldown: float = 0.5
@export var resolve_combo_award: float = 10.0

var comboStep: int = 0
var isAttacking: bool = false

var attack1Done = false
var attack2Done = false
var attack3Done = false

var combo_hits: Array[bool] = [false, false, false]
var cooldown_left: float = 0.0
var attack_queued = false
var step_is_running = false

func _ready() -> void:
	if not is_instance_valid(inventoryC.cWeapon):
		return
	
	var weapon_collider = inventoryC.cWeapon.hurtbox as WeaponCollider
	if weapon_collider:
		weapon_collider.hit_landed.connect(_on_weapon_hit_landed)

func _on_weapon_hit_landed(_target: Node3D) -> void:
	if comboStep >= 1 and comboStep <= 3:
		combo_hits[comboStep - 1] = true

func Attack() -> void:
	if cooldown_left > 0.0:
		return

	if isAttacking:
		attack_queued = true
	elif comboStep == 0:
		comboStep = 1
	
func process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)
	if step_is_running:
		return
	
	match comboStep:
		1:
			if attack1Done:
				return
			
			isAttacking = true
			attack1Done = true
			step_is_running = true
			combo_hits[0] = false
			await animC.play_anim(&"Attack1")
			step_is_running = false
			_finish_step(2)
		
		2:
			if attack2Done:
				return
			
			attack2Done = true
			step_is_running = true
			combo_hits[1] = false
			await animC.play_anim(&"Attack2")
			step_is_running = false
			_finish_step(3)
		
		3:
			if attack3Done:
				return
			
			attack3Done = true
			step_is_running = true
			combo_hits[2] = false
			await animC.play_anim(&"Attack3")
			step_is_running = false

			if combo_hits[0] and combo_hits[1] and combo_hits[2]:
				resolveC.gainResolve(resolve_combo_award)
				print("Resolve gained!")

			_reset_combo()

func _finish_step(next_step: int) -> void:
	if attack_queued:
		attack_queued = false
		comboStep = next_step
	
	else:
		_reset_combo()

func _reset_combo() -> void:
	comboStep = 0
	cooldown_left = attack_cooldown
	isAttacking = false
	attack_queued = false
	attack1Done = false
	attack2Done = false
	attack3Done = false
	combo_hits[0] = false
	combo_hits[1] = false
	combo_hits[2] = false



