extends TextureRect

var tween : Tween
var fade_tween : Tween
@onready var init_position = self.position
@onready var fade_timer : Timer

func _ready() -> void:
	fade_timer = Timer.new()
	fade_timer.wait_time = 4.0
	fade_timer.one_shot = true
	fade_timer.timeout.connect(fade_away)
	SignalBus.unlock_spell.connect(show_new_spell_icon)
	# fade_timer.autostart = true
	add_child(fade_timer)
	bob_up_and_down()
	self.hide()


func show_new_spell_icon(_element : SignalBus.Element):
	self.modulate.a = 1.0
	self.show()
	fade_timer.start()

func fade_away():
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	
	fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	fade_tween.finished.connect(self.hide)

func bob_up_and_down():
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	tween.tween_property(self, "position:y", init_position.y - 10, 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", init_position.y + 10, 2.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", init_position.y, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(bob_up_and_down)
