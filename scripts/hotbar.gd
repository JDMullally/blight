extends Control
class_name Hotbar

@onready var water_progress_bar: TextureProgressBar = %WaterProgressBar
@onready var love_progress_bar: TextureProgressBar = %LoveProgressBar
@onready var light_progress_bar: TextureProgressBar = %LightProgressBar
@onready var song_progress_bar: TextureProgressBar = %SongProgressBar
var shake_tween : Tween
#@onready var progress_bar: ProgressBar = $ProgressBar
@onready var sprint_progress_bar: TextureProgressBar = %SprintProgressBar
@onready var health: TextureProgressBar = %Health
@onready var water_select: Sprite2D = %WaterSelect
@onready var love_select: Sprite2D = %LoveSelect
@onready var light_select: Sprite2D = %LightSelect
@onready var song_select: Sprite2D = %SongSelect

func _ready():
	SignalBus.select_spell.connect(select_spell_highlight)
	SignalBus.update_player_health.connect(update_health)
	SignalBus.update_sprint_progress.connect(update_sprint)
	SignalBus.unlock_spell.connect(unlock_spell)
	SignalBus.spell_error_message.connect(error_shake_button)
	SignalBus.update_prog_bars.connect(update_progress_bars)
	
	water_progress_bar.hide()
	light_progress_bar.hide()
	song_progress_bar.hide()

func update_health(value : int):
	var clamped_value = clampf(value, 0, 100.0)
	health.value = clamped_value

func update_progress_bars(water_prog : float, love_prog : float, light_prog : float, song_prog : float):
	water_progress_bar.value = get_prog(water_prog, water_progress_bar.min_value, water_progress_bar.max_value)
	love_progress_bar.value = get_prog(love_prog, love_progress_bar.min_value, love_progress_bar.max_value)
	light_progress_bar.value = get_prog(light_prog, light_progress_bar.min_value, light_progress_bar.max_value)
	song_progress_bar.value = get_prog(song_prog, song_progress_bar.min_value, song_progress_bar.max_value)

func update_sprint(sprint_prog : float):
	sprint_progress_bar.value = get_prog(sprint_prog, sprint_progress_bar.min_value, sprint_progress_bar.max_value)

func get_prog(percentage : float, min_val : float, max_val : float) -> float:
		return clampf(max_val * percentage, min_val, max_val)

func unlock_spell(element : SignalBus.Element):
	match element:
		SignalBus.Element.Water:
			water_progress_bar.show()
		SignalBus.Element.Love:
			love_progress_bar.show()
		SignalBus.Element.Light:
			light_progress_bar.show()
		SignalBus.Element.Song:
			song_progress_bar.show()

func select_spell_highlight(element : SignalBus.Element):
	water_select.hide()
	love_select.hide()
	light_select.hide()
	song_select.hide()
	match element:
		SignalBus.Element.Water:
			water_select.show()
		SignalBus.Element.Love:
			love_select.show()
		SignalBus.Element.Light:
			light_select.show()
		SignalBus.Element.Song:
			song_select.show()

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
				SignalBus.select_spell.emit(SignalBus.Element.Love)
			Key.KEY_2:
				SignalBus.select_spell.emit(SignalBus.Element.Water)
			Key.KEY_3:
				SignalBus.select_spell.emit(SignalBus.Element.Light)
			Key.KEY_4:
				SignalBus.select_spell.emit(SignalBus.Element.Song)
