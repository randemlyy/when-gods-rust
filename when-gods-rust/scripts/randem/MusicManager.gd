extends Node

@export var menu_music: AudioStream
@export var gameplay_music: AudioStream

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_music(track: AudioStream, volume_db: float = -12.0) -> void:
	if track == null:
		return
	
	if music_player.playing and music_player.stream == track:
		return
	
	music_player.stop()
	music_player.stream = track
	music_player.volume_db = volume_db
	music_player.play()

func play_menu_music() -> void:
	play_music(menu_music)

func play_gameplay_music() -> void:
	play_music(gameplay_music)
