extends Node

@export var menu_music: AudioStream
@export var gameplay_music: AudioStream
@onready var music_player: AudioStreamPlayer = $MusicPlayer

#func _process(delta: float) -> void:
	#await get_tree().create_timer(1).timeout
	#if music_player.stream != null:
		#print(music_player.stream)
	
func play_music(track: AudioStream) -> void:
	if track == null:
		return
	if music_player.playing and music_player.stream == track:
		return
	
	music_player.playing = false
	music_player.stream = track
	music_player.playing = true

func play_menu_music() -> void:
	play_music(menu_music)

func play_gameplay_music() -> void:
	play_music(gameplay_music)
