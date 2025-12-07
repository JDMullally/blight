extends Node2D
class_name Wisp

@export var element : SignalBus.Element
@export var active : bool = false
@onready var point_light_2d: PointLight2D = $PointLight2D
# @onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var water_particle: GPUParticles2D = $WaterParticle
@onready var light_particle: GPUParticles2D = $LightParticle
@onready var song_particle: GPUParticles2D = $SongParticle
@onready var love_particle: GPUParticles2D = $LoveParticle

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
			point_light_2d.color = Color("2b67cb")
			water_particle.emitting = true
			light_particle.emitting = false
			song_particle.emitting = false
			love_particle.emitting = false
		SignalBus.Element.Love:
			point_light_2d.color = Color("ff88ba")
			water_particle.emitting = false
			light_particle.emitting = false
			song_particle.emitting = false
			love_particle.emitting = true
		SignalBus.Element.Light:
			point_light_2d.color = Color("ffecbf")
			water_particle.emitting = false
			light_particle.emitting = true
			song_particle.emitting = false
			love_particle.emitting = false
		SignalBus.Element.Song:
			point_light_2d.color = Color("cbae98")
			water_particle.emitting = false
			light_particle.emitting = false
			song_particle.emitting = true
			love_particle.emitting = false

func _ready() -> void:
	tween = create_tween()
	tween.finished.connect(float_tween)
	float_tween()
	set_light_color()
	show_wisp()
