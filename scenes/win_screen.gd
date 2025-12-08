extends TextureRect

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio_stream_player.play()

func restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func quit():
	get_tree().quit(0)

func _on_title_screen_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")


func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play()
