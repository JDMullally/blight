extends AnimatedSprite2D
class_name Well

const MAX_THRESHOLD : int = 4
const WIDTH : float = 640.0
const HEIGHT : float = 320.0
const MAX_HITS : int = 1

signal all_done

@onready var increment : float = 640.0
@onready var threshold : int = 0
@onready var hits = 0

func increment_well():
	hits += 1
	if hits < MAX_HITS:
		return
	
	if threshold < MAX_THRESHOLD:
		hits = 0
		threshold = clampi(threshold + 1, 0, MAX_THRESHOLD)
		var current_atlas_texture : AtlasTexture = self.texture
		current_atlas_texture.region = Rect2(increment * threshold, 0.0, WIDTH, HEIGHT)
		if threshold == MAX_THRESHOLD:
			all_done.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Water):
			self.increment_well()
			area.dissapear()
