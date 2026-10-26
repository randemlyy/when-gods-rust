class_name AnimationComponent
extends Node

@onready var animation_player: AnimationPlayer = $"../../TestAnimPlayer"



#func process(is_moving: bool, is_staggered: bool) -> void:
	#var animation := &"Staggered" if is_staggered else (&"Walk2" if is_moving else &"Idle")
	#if animation_player.current_animation != animation:
		#animation_player.play(animation)

func play_anim(animName:String) -> void:
	animation_player.play(animName)

	while animation_player.is_playing() and animation_player.current_animation == animName:
		await get_tree().process_frame

func IsAnimPlaying() -> bool:
	return animation_player.is_playing()

#func AnimFinished(AnimName:String) -> bool:
	#return animation_player.animation_finished(AnimName)
