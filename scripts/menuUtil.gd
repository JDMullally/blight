extends Control

@onready var volume: Control = $Volume
@onready var showing_volume = false
@onready var settings_label: Label = $SettingsLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_label.text = "Show Settings" if !showing_volume else "Hide Settings"
	audio_stream_player.play(0.0)

func start() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func resume() -> void:
	get_tree().paused = false
	self.hide()

func restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func settings() -> void:
	if showing_volume:
		volume.hide()
	else:
		volume.show()
	showing_volume = !showing_volume
	settings_label.text = "Show Settings" if !showing_volume else "Hide Settings"

func quit() -> void:
	get_tree().quit(0)

func title() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play(60.0)
