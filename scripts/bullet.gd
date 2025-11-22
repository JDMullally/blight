extends Area2D
class_name Bullet

@export var speed : float = 150.0
var velocity : Vector2 = Vector2.ZERO

@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var timer: Timer = $Timer
var element : Element = Element.Water
const LOVE_PARTICLE_UID = "uid://ccf5jhypapbd7"

enum Element {Light, Love, Water, Song}

func _center_polygon(poly : PackedVector2Array) -> PackedVector2Array:
	var center := Vector2.ZERO
	for p in poly:
		center += p
	center /= poly.size()

	var result := PackedVector2Array()
	for p in poly:
		result.append(p - center)
	return result


func setup(poly : PackedVector2Array, start_pos : Vector2, direction : Vector2) -> void:
	timer.start()
	var local_poly := _center_polygon(poly)
	
	var new_poly = Polygon2D.new()
	new_poly.polygon = local_poly
	# new_poly.color = Color(0.8, 0.4, 0.7)
	new_poly.color = Color(0,.6,.8)
	new_poly.modulate.a = 0.7
	add_child(new_poly)

	if len(local_poly) <= 30:
		for point in local_poly:
			var gpu_part : GPUParticles2D = load(LOVE_PARTICLE_UID).instantiate() as GPUParticles2D
			gpu_part.position = point
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
			hitbox.polygon = local_poly
	else:
		var multiplier : float = len(local_poly) / 30.0
		for i in range(30):
			var index = int(ceil(i * multiplier))
			var gpu_part : GPUParticles2D = load(LOVE_PARTICLE_UID).instantiate() as GPUParticles2D
			gpu_part.position = local_poly[index]
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
			hitbox.polygon = local_poly
			# print(index)
	global_position = start_pos
	velocity = direction.normalized() * speed

	if direction.normalized().x >= 0:
		self.scale = Vector2(0.1, 0.1)
	elif direction.normalized().x < 0:
		self.scale = Vector2(0.1, -0.1)
	rotation = direction.angle()
	
	# hitbox.visible = true

func _process(_delta: float) -> void:
	if timer.is_stopped():
		self.queue_free()

func _physics_process(delta : float) -> void:
	global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	print(body.name)
