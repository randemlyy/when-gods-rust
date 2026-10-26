class_name Weapon
extends Node3D

@export var hurtbox: Area3D
@export var collider: CollisionShape3D
@export var rawDamage: int = 10
@export var hit_stagger_duration: float = 0.35

func _ready() -> void:
	deactivate_hurtbox()

func activate_weapon() -> void:
	show()
	deactivate_hurtbox()
	
func deactivate_weapon() -> void:
	hide()
	deactivate_hurtbox()

func activate_hurtbox() -> void:
	if hurtbox.has_method("begin_swing"):
		hurtbox.call("begin_swing")
	collider.disabled = false

func deactivate_hurtbox() -> void:
	collider.disabled = true


#
#var comboStep: int = 0
#var canCombo: bool = false
#var canCrit: bool = false
#var canStagger: bool = false
#var isAttacking: bool = false
#
#@export var attackArea: Area3D
#@export var maxCombo: int = 3
#@export var hit_stagger_duration: float = 0.65
#@export var damage: float = 10.0
#@export var resolve_gain_combo: float = 10.0
#@export var combo_cooldown: float = 0.6
#
#var resolveC: ResolveComponent
#var upgradeC: UpgradeComponent
#
#var bodies_hit_this_swing: Array[Node3D] = []
#var is_current_attack_crit: bool = false
#var current_swing_hit = false
#var successful_swings = 0
#var combo_cooldown_left: float = 0.0
#
#func _ready() -> void:
	#if attackArea == null:
		#push_error('bradar put attack area')
		#return
	#attackArea.monitoring = false
	#
#func Attack(resolve:ResolveComponent, anim:AnimationPlayer):
	#if combo_cooldown_left > 0.0:
		#return
	#if not is_instance_valid(anim):
		#return
#
	#resolveC = resolve
	#
	#if not isAttacking:
		#comboStep = 0
		#successful_swings = 0
		#is_current_attack_crit = false
		#startAttack(anim)
	#
	#elif comboStep < maxCombo - 1 and canCrit:
		#comboStep+=1
		#is_current_attack_crit = true
		#startAttack(anim)
		#
	#elif comboStep < maxCombo - 1 and canCombo:
		#comboStep+=1
		#is_current_attack_crit = false
		#startAttack(anim)
#
#func startAttack(anim:AnimationPlayer):
	#if attackArea == null or anim == null:
		#return
	#isAttacking = true
	#current_swing_hit = false
	#bodies_hit_this_swing.clear()
	#
	#if not anim.animation_finished.is_connected(_on_attack_animation_finished):
		#anim.animation_finished.connect(_on_attack_animation_finished)
		#
	#var animName = "Attack_" + str(comboStep+1)
	#anim.play(animName, -1, 1.5)
	#print(animName)
	#
	##anim.animation_finished.connect(func(name:StringName):
		##isAttacking = false
		##comboStep = 0
		##attackArea.set_deferred("monitoring", false))
		#
#func _physics_process(delta: float) -> void:
	#if attackArea.monitoring:
		#for target in attackArea.get_overlapping_bodies():
			#_try_hit(target)
			#
	#if isAttacking and not canStagger:
		#attackArea.set_deferred("monitoring", true)
	#
	#if combo_cooldown_left > 0.0:
		#combo_cooldown_left = maxf(0.0, combo_cooldown_left - delta)
		#
#func _try_hit(target: Node3D) -> void:
	#if target.is_in_group("Player"):
		#return
	#if canStagger:
		#return
	#if target in bodies_hit_this_swing:
		#return
	#if not target.has_node("HealthComponent"):
		#return
		#
	#bodies_hit_this_swing.append(target)
	#
	#var damage_bonus = 0.0
	#if is_instance_valid(upgradeC):
		#damage_bonus = upgradeC.attack_damage_bonus
	#
	#var crit_mult = 1.5 if is_current_attack_crit else 1.0
	#var final_damage := roundi(damage * (1.0 + damage_bonus / 100.0) * crit_mult)
	#var target_stagger = target.get_node_or_null("StaggerComponent") as StaggerComponent
	#if target_stagger and target_stagger.is_staggered:
		#final_damage = roundi(final_damage * 1.3)
	#target.get_node("HealthComponent").call("take_damage", final_damage)
	#HitStop.request(0.07 if is_current_attack_crit else 0.04)
	#
	#if not current_swing_hit:
		#current_swing_hit = true
		#successful_swings += 1
		#
	#print("Body ", target, " took ", final_damage, " damage")
#
#func _on_attack_animation_finished(animation_name: StringName) -> void:
	#if not str(animation_name).begins_with("Attack_"):
		#return
	#
	#combo_cooldown_left = combo_cooldown
	#
	#isAttacking = false
	#comboStep = 0
	#canCombo = false
	#canCrit = false
	#is_current_attack_crit = false
	#attackArea.set_deferred("monitoring", false)
