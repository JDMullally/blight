extends Control
class_name Hotbar

@onready var water_progress_bar: TextureProgressBar = %WaterProgressBar
@onready var love_progress_bar: TextureProgressBar = %LoveProgressBar
@onready var light_progress_bar: TextureProgressBar = %LightProgressBar
@onready var song_progress_bar: TextureProgressBar = %SongProgressBar
@onready var healthbar : ProgressBar = $ProgressBar
var shake_tween : Tween

func _ready():
	SignalBus.spell_error_message.connect(error_shake_button)
	SignalBus.update_prog_bars.connect(update_progress_bars)
	#love_progress_bar.hide()
	#light_progress_bar.hide()
	#song_progress_bar.hide()

func update_progress_bars(water_prog : float, love_prog : float, light_prog : float, song_prog : float):
	update_progress_bar(SignalBus.Element.Water, water_prog)
	update_progress_bar(SignalBus.Element.Love, love_prog)
	update_progress_bar(SignalBus.Element.Light, light_prog)
	update_progress_bar(SignalBus.Element.Song, song_prog)

func update_progress_bar(element : SignalBus.Element, percentage : float):
	match element:
		SignalBus.Element.Water:
			water_progress_bar.value = clampf(water_progress_bar.max_value * percentage, water_progress_bar.min_value, water_progress_bar.max_value)
		SignalBus.Element.Love:
			love_progress_bar.value = clampf(love_progress_bar.max_value * percentage, love_progress_bar.min_value, love_progress_bar.max_value)
		SignalBus.Element.Light:
			light_progress_bar.value = clampf(light_progress_bar.max_value * percentage, light_progress_bar.min_value, light_progress_bar.max_value)
		SignalBus.Element.Song:
			song_progress_bar.value = clampf(song_progress_bar.max_value * percentage, song_progress_bar.min_value, song_progress_bar.max_value)

func error_shake_button(element : SignalBus.Element):
	var to_be_selected_progress_bar : TextureProgressBar
	
	match element:
		SignalBus.Element.Water:
			to_be_selected_progress_bar = water_progress_bar
		SignalBus.Element.Love:
			to_be_selected_progress_bar = love_progress_bar
		SignalBus.Element.Light:
			to_be_selected_progress_bar = light_progress_bar
		SignalBus.Element.Song:
			to_be_selected_progress_bar = song_progress_bar

	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
		
	shake_tween = get_tree().create_tween()

	# var original_size = to_be_selected_progress_bar.scale
	shake_tween.tween_property(to_be_selected_progress_bar, "rotation", -.1, 0.1)
	shake_tween.tween_property(to_be_selected_progress_bar, "rotation", .1, 0.2)
	shake_tween.tween_property(to_be_selected_progress_bar, "rotation", 0, 0.05)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			Key.KEY_1:
				SignalBus.select_spell.emit(SignalBus.Element.Water)
			Key.KEY_2:
				SignalBus.select_spell.emit(SignalBus.Element.Love)
			Key.KEY_3:
				SignalBus.select_spell.emit(SignalBus.Element.Light)
			Key.KEY_4:
				SignalBus.select_spell.emit(SignalBus.Element.Song)
