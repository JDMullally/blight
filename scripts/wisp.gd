extends Node2D
class_name Wisp

@export var element : SignalBus.Element
@export var active : bool = false
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var wand : Node2D = get_tree().get_first_node_in_group("wand")

@onready var tween : Tween
@onready var start_pos = position.y

func hide_wisp():
	self.hide()
	active = false

func show_wisp():
	self.show()
	active = true



func float_tween():
	tween.kill()
	tween = create_tween()
	tween.finished.connect(float_tween)
	
	var bob_amount = randf_range(3.0, 7.0)
	var duration = randf_range(1.5, 2.5)
	
	tween.tween_property(self, "position:y", start_pos - bob_amount, duration)
	tween.tween_property(self, "position:y", start_pos, duration)
	

func set_light_color():
	match element:
		SignalBus.Element.Water:
			point_light_2d.color = Color("#f1f1f3")
		SignalBus.Element.Love:
			point_light_2d.color = Color("#f1f1f3")
		SignalBus.Element.Light:
			point_light_2d.color = Color("#f1f1f3")
		SignalBus.Element.Song:
			point_light_2d.color = Color("#f1f1f3")
		_:
			point_light_2d.color = Color("#f1f1f3")

func shoot_bullet_from_me():
	pass#wand.

func _ready() -> void:
	tween = create_tween()
	tween.finished.connect(float_tween)
	float_tween()
	set_light_color()
	show_wisp()
