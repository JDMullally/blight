extends Area2D

@export var speed : float = 150.0

var velocity : Vector2 = Vector2.ZERO

@onready var hitbox: CollisionPolygon2D = $Hitbox
@onready var timer: Timer = $Timer
const BASIC_PARTICLES_UID = "uid://ccf5jhypapbd7"
const SPELL_SHADER_UID = "uid://bypgr602phyh7"


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
	new_poly.color = Color(0.8, 0.4, 0.7)
	new_poly.modulate.a = 0.7
	add_child(new_poly)

	#
	#var new_shader : Shader = load(SPELL_SHADER_UID)
	#print(new_shader)
	#new_shader.set("shader_param/tint_color", Color(0.0, 0.2, 1.0))
	#new_shader.set("shader_param/tint_alpha", 0.7)
	#self.material.shader = new_shader
	#print(self.material)
	#

	if len(local_poly) <= 30:
		for point in local_poly:
			var gpu_part : GPUParticles2D = load(BASIC_PARTICLES_UID).instantiate() as GPUParticles2D
			gpu_part.position = point
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
	else:
		var multiplier : float = len(local_poly) / 30.0
		for i in range(30):
			var index = int(ceil(i * multiplier))
			var gpu_part : GPUParticles2D = load(BASIC_PARTICLES_UID).instantiate() as GPUParticles2D
			gpu_part.position = local_poly[index]
			gpu_part.scale = Vector2(100,100)
			hitbox.add_child(gpu_part)
			# print(index)
	global_position = start_pos
	velocity = direction.normalized() * speed

	if direction.normalized().x >= 0:
		self.scale = Vector2(0.1, 0.1)
	elif direction.normalized().x < 0:
		self.scale = Vector2(0.1, -0.1)
	rotation = direction.angle()
	
	hitbox.polygon = local_poly
	hitbox.visible = true

func _process(_delta: float) -> void:
	if timer.is_stopped():
		self.queue_free()

func _physics_process(delta : float) -> void:
	global_position += velocity * delta
