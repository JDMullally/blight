extends Control


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	self.hide()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
	
func _on_settings_button_button_down() -> void:
	$SettingsButton/Label.set_position($SettingsButton/Label.position + Vector2(6,6))



func _on_quit_game_button_pressed() -> void:
	get_tree().quit(0)


func _on_music_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_sfx_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_grey_scale_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_title_screen_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_credits_button_button_down() -> void:
	$CreditsButton/Label.set_position($CreditsButton/Label.position + Vector2(6,6))
