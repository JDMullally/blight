extends Node2D
class_name SongShrine

@onready var successes : int = 0
@onready var simon_says_key : Array[int] = []
@onready var player_simon_says : Array[int] = []
@onready var note_block: AnimatedSprite2D = $Note_Block

@onready var reset_button_left: AnimatedSprite2D = $"Reset Button Left"
@onready var reset_button_right: AnimatedSprite2D = $"Reset Button Right"

@onready var bottom_left_button: AnimatedSprite2D = $"Bottom Left Button"
@onready var bottom_right_button: AnimatedSprite2D = $"Bottom Right Button"
@onready var top_left_button: AnimatedSprite2D = $"Top Left Button"
@onready var top_right_button: AnimatedSprite2D = $"Top Right Button"

@onready var birdie_top_right: AnimatedSprite2D = $"Birdie Top Right"
@onready var birdie_top_left: AnimatedSprite2D = $"Birdie Top Left"
@onready var birdie_bottom_left: AnimatedSprite2D = $"Birdie Bottom Left"
@onready var birdie_bottom_right: AnimatedSprite2D = $"Birdie Bottom Right"

@onready var audio_stream_player: AudioStreamPlayer2D = %AudioStreamPlayer
@onready var audio_stream_player_2: AudioStreamPlayer2D = %AudioStreamPlayer2
@onready var audio_stream_player_3: AudioStreamPlayer2D = %AudioStreamPlayer3
@onready var audio_stream_player_4: AudioStreamPlayer2D = %AudioStreamPlayer4

@onready var animation_timer : Timer
@onready var simon_says_index = 0

func _ready() -> void:
	animation_timer = Timer.new()
	animation_timer.one_shot = true
	animation_timer.wait_time = 0.8
	add_child(animation_timer)
	animation_timer.timeout.connect(simon_says_recursive)
	generate_new_simon_says()

func increment_success_and_activate_bird_sprite():
	successes += 1
	activate_corresponding_birds()

func play_simon_says():
	simon_says_index = 0
	animation_timer.start()

func simon_says_recursive():
	if simon_says_index == 4:
		return
	else:
		play_right_animation_and_sound(simon_says_key[simon_says_index])
		simon_says_index = clampi(simon_says_index + 1, 0, 4)
		animation_timer.start()
		

func play_right_animation_and_sound(num : int):
	match num:
		1:
			play_button_animation(top_left_button)
			audio_stream_player.play()
		2:
			play_button_animation(top_right_button)
			audio_stream_player_2.play()
		3:
			play_button_animation(bottom_right_button)
			audio_stream_player_3.play()
		4:
			play_button_animation(bottom_left_button)
			audio_stream_player_4.play()
		_:
			return


func activate_corresponding_birds():
	match successes:
		1:
			birdie_top_left.play("singing")
		2:
			birdie_top_right.play("singing")
		3:
			birdie_bottom_right.play("singing")
		4:
			birdie_bottom_left.play("singing")
			SignalBus.complete_shrine.emit()
			SignalBus.unlock_spell.emit(SignalBus.Element.Light)
			SignalBus.debuff_shrine.emit(SignalBus.Element.Song)
		_:
			birdie_top_left.play("singing")
			birdie_top_right.play("singing")
			birdie_bottom_right.play("singing")
			birdie_bottom_left.play("singing")


func generate_new_simon_says():
	if successes < 4:
		simon_says_key = [randi_range(1,4), randi_range(1,4), randi_range(1,4), randi_range(1,4)]
		play_simon_says()

func add_and_check(number : int):
	player_simon_says.append(number)
	var current_length = player_simon_says.size()
	for i in range(current_length):
		if player_simon_says[i] != simon_says_key[i]:
			player_simon_says.clear()
			note_block.play("default_4")
			play_simon_says()
		else:
			if i == 0:
				note_block.play("one_right_4")
			elif i == 1:
				note_block.play("two_right_4")
			elif i == 2:
				note_block.play("three_right_4")
			elif i == 3:
				note_block.play("four_right_4")
				
	if player_simon_says.size() == 4:
		player_simon_says.clear()
		increment_success_and_activate_bird_sprite()
		generate_new_simon_says()
		note_block.play("four_right_4")

func _on_bottom_right_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Song):
			area.dissapear()
			play_right_animation_and_sound(3)
			add_and_check(3)

func play_button_animation(animated_sprite : AnimatedSprite2D):
	if animated_sprite.animation == "pressed":
		animated_sprite.frame = 0
		animated_sprite.play("pressed")
	else:
		animated_sprite.play("pressed")

func _on_bottom_left_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Song):
			area.dissapear()
			play_right_animation_and_sound(4)
			add_and_check(4)

func _on_top_right_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Song):
			area.dissapear()
			play_right_animation_and_sound(2)
			add_and_check(2)

func _on_top_left_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Song):
			area.dissapear()
			play_right_animation_and_sound(1)
			add_and_check(1)
