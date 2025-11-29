extends TextureRect

var showing = false
@onready var water_area: TextureRect = $Control/WaterArea
@onready var love_area: TextureRect = $Control/LoveArea
@onready var light_area: TextureRect = $Control/LightArea
@onready var song_area: TextureRect = $Control/SongArea
@onready var water: TextureRect = $Control/Water
@onready var song: TextureRect = $Control/Song
@onready var light: TextureRect = $Control/Light
@onready var heart: TextureRect = $Control/Heart
@onready var love_button: TextureButton = $Control/LoveButton
@onready var song_button: TextureButton = $Control/SongButton
@onready var water_button: TextureButton = $Control/WaterButton
@onready var light_button: TextureButton = $Control/LightButton

func _ready() -> void:
	SignalBus.unlock_spell.connect(unlock_spell)
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	love_button.hide()
	song_button.hide()
	light_button.hide()
	_on_water_button_pressed()

func unlock_spell(element : SignalBus.Element):
	match element:
		SignalBus.Element.Water:
			water_button.show()
		SignalBus.Element.Love:
			love_button.show()
		SignalBus.Element.Light:
			light_button.show()
		SignalBus.Element.Song:
			song_button.show()

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == Key.KEY_TAB:
		show_or_hide()

func show_or_hide():
	if self.showing:
		self.hide()
	else:
		self.show()
	get_tree().paused = !self.showing
	self.showing = !self.showing

func restart():
	get_tree().paused = false
	self.showing = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func quit():
	get_tree().quit(0)

func title_screen():
	get_tree().paused = false
	self.showing = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_love_button_pressed() -> void:
	water_area.hide()
	love_area.show()
	light_area.hide()
	song_area.hide()
	heart.show()
	song.hide()
	light.hide()
	water.hide()

func _on_song_button_pressed() -> void:
	water_area.hide()
	love_area.hide()
	light_area.hide()
	song_area.show()
	heart.hide()
	song.show()
	light.hide()
	water.hide()

func _on_water_button_pressed() -> void:
	water_area.show()
	love_area.hide()
	light_area.hide()
	song_area.hide()
	heart.hide()
	song.hide()
	light.hide()
	water.show()

func _on_light_button_pressed() -> void:
	water_area.hide()
	love_area.hide()
	light_area.show()
	song_area.hide()
	heart.hide()
	song.hide()
	light.show()
	water.hide()
