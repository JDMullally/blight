extends RichTextLabel
class_name HelpText

var pixel_font = preload("res://art/ui/arcade_font/retro-pixel-arcade.ttf")

func _ready() -> void:
	SignalBus.update_player_text.connect(update_my_text)
	bbcode_enabled = true
	scroll_active = false
	add_theme_font_override("normal_font", pixel_font)
	add_theme_color_override("default_color", Color.WHITE)
	
func update_my_text(string : String):
	self.clear()
	self.append_text("[font_size=24]")
	self.append_text(string)
	self.append_text("[/font_size]")
