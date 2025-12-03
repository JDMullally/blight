extends RichTextLabel
class_name HelpText

func _ready() -> void:
	SignalBus.update_player_text.connect(update_my_text)
	bbcode_enabled = true
	scroll_active = false
	
func update_my_text(string : String):
	self.clear()
	self.append_text("[font_size=48]")
	self.append_text(string)
	self.append_text("[/font_size]")
