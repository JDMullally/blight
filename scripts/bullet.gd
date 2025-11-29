extends Area2D
class_name Bullet

@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var timer: Timer = $Timer

const WATER_PARTICLE_UID = "uid://det0c7hb3ewvg"
const LIGHT_PARTICLE_UID = "uid://3kto6lejsrb6"
const SONG_PARTICLE_UID = "uid://x68802oujnpe"
const LOVE_PARTICLE_UID = "uid://bjwstm6sdkfde"

var velocity : Vector2 = Vector2.ZERO
var stats : BulletStats

func _center_polygon(poly : PackedVector2Array) -> PackedVector2Array:
	var center := Vector2.ZERO
	for p in poly:
		center += p
	center /= poly.size()

	var result := PackedVector2Array()
	for p in poly:
		result.append(p - center)
	return result


func setup(poly : PackedVector2Array, start_pos : Vector2, direction : Vector2, bullet_stats : BulletStats) -> void:
	# timer.wait_time = bullet_stats.cooldown
	timer.start()
	var local_poly := _center_polygon(poly)
	self.stats = bullet_stats
	var new_poly = Polygon2D.new()
	var usable_gpu_part : GPUParticles2D
	new_poly.polygon = local_poly
	new_poly.modulate.a = 0.5
	match bullet_stats.element:
		SignalBus.Element.Water:
			new_poly.color = Color("adf6ff")
			new_poly.modulate.a = 0.8
			usable_gpu_part = load(WATER_PARTICLE_UID).instantiate() as GPUParticles2D
		SignalBus.Element.Love:
			new_poly.color = Color("ff88ba")
			usable_gpu_part = load(LOVE_PARTICLE_UID).instantiate() as GPUParticles2D
		SignalBus.Element.Light:
			new_poly.color = Color("ffecbf")
			usable_gpu_part = load(LIGHT_PARTICLE_UID).instantiate() as GPUParticles2D
		SignalBus.Element.Song:
			new_poly.color = Color("cbae98")
			usable_gpu_part = load(SONG_PARTICLE_UID).instantiate() as GPUParticles2D
			new_poly.modulate.a = 0.7
	add_child(new_poly)

	if len(local_poly) <= 30:
		for point in local_poly:
			var gpu_part = usable_gpu_part.duplicate()
			gpu_part.position = point
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
			hitbox.polygon = local_poly
	else:
		var multiplier : float = len(local_poly) / 30.0
		for i in range(30):
			var index = int(ceil(i * multiplier))
			var gpu_part = usable_gpu_part.duplicate()
			gpu_part.position = local_poly[index]
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
			hitbox.polygon = local_poly
	global_position = start_pos
	if stats:
		velocity = direction.normalized() * stats.speed

	if direction.normalized().x >= 0:
		self.scale = Vector2(0.1, 0.1)
	elif direction.normalized().x < 0:
		self.scale = Vector2(0.1, -0.1)
	rotation = direction.angle()
	
	# hitbox.visible = true

func is_element(element : SignalBus.Element):
	return stats and element == stats.element

func _process(_delta: float) -> void:
	if timer.is_stopped() or stats.hits_spent():
		dissapear()

func dissapear() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): self.queue_free())

func _physics_process(delta : float) -> void:
	global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Monster:
		if body.monster_stats.affinity == self.stats.element:
			body.take_damage(stats.damage)
		body.apply_affix(self.stats.element, self.stats.debuff_time)
		stats.decrement_hits()
		if stats.hits_spent():
			dissapear()
