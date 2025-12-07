extends Control

var master_index= AudioServer.get_bus_index("Master")
var sfx_index= AudioServer.get_bus_index("SFX")
var music_index= AudioServer.get_bus_index("Music")

func _ready():
	$MasterVolume.value = AudioServer.get_bus_volume_linear(master_index)
	$MusicVolume.value = AudioServer.get_bus_volume_linear(music_index)
	$SFXVolume.value = AudioServer.get_bus_volume_linear(sfx_index)
	_on_master_volume_value_changed(0.5)
	_on_music_volume_value_changed(0.4)


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(master_index, value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_index, value)


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_index, value)
	
	
