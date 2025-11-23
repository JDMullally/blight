extends TextureRect

var showing = false
@onready var water_area: TextureRect = $Control/WaterArea
@onready var love_area: TextureRect = $Control/LoveArea
@onready var light_area: TextureRect = $Control/LightArea
@onready var song_area: TextureRect = $Control/SongArea

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

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

func _on_song_button_pressed() -> void:
	water_area.hide()
	love_area.hide()
	light_area.hide()
	song_area.show()

func _on_water_button_pressed() -> void:
	water_area.show()
	love_area.hide()
	light_area.hide()
	song_area.hide()

func _on_light_button_pressed() -> void:
	water_area.hide()
	love_area.hide()
	light_area.show()
	song_area.hide()
