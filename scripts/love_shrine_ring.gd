extends Area2D
class_name Ring

const MAX_RING_TIME : float = 30.0
const MAX_THRESHOLD : int = 640

@onready var ring_time : float = 0
@onready var completed : bool = false
@onready var within_ring : bool = false
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

@onready var increment : float = 640.0
@onready var threshold : int = 0

func _process(delta: float) -> void:
	if !completed:
		update_ring_time(delta)
		update_animation()
		check_ring_time()

func update_ring_time(delta : float):
	if within_ring:
		ring_time = clampf(ring_time + delta, 0.0, 60.0)

func check_ring_time():
	if ring_time >= MAX_RING_TIME:
		completed = true
		point_light_2d.energy = 2.0
		SignalBus.unlock_spell.emit(SignalBus.Element.Light)
		SignalBus.complete_shrine.emit()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		within_ring = true

func update_animation():
	threshold = clampi(int(ring_time/(MAX_RING_TIME/8)), 0, MAX_THRESHOLD * 7)
	var current_atlas_texture : AtlasTexture = sprite_2d.texture
	current_atlas_texture.region = Rect2(increment * threshold, 0.0, MAX_THRESHOLD, MAX_THRESHOLD)
	point_light_2d.energy = clampf(.4 + ring_time / MAX_RING_TIME, .4, 1.4) if within_ring else 0.0

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		within_ring = false
