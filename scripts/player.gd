extends CharacterBody2D
class_name Player

const SPEED : int = 100
const KNOCKBACK : int = 200
var current_knockback_vector : Vector2 = Vector2.ZERO
var input_vector : Vector2 = Vector2.ZERO
var impulse_decay_timer : Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wand: Node2D = $Wand

func apply_impulse(dir : Vector2):
	current_knockback_vector = current_knockback_vector + KNOCKBACK * dir

func _ready() -> void:
	SignalBus.hurt_player.connect(hit_player)
	impulse_decay_timer = Timer.new()
	impulse_decay_timer.wait_time = .05
	impulse_decay_timer.one_shot = true
	add_child(impulse_decay_timer)
	handle_animation(Vector2.ZERO, Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_vector * SPEED + Vector2(current_knockback_vector.x, current_knockback_vector.y)
	handle_animation(input_vector, velocity)
	decay_knockback()
	move_and_slide()

func hit_player(monster_damage : int, monster_global_position : Vector2):
	print(monster_damage)
	apply_impulse((self.global_position - monster_global_position).normalized())

func decay_knockback():
	if impulse_decay_timer.is_stopped():
		impulse_decay_timer.start()
		current_knockback_vector = Vector2.ZERO if abs(current_knockback_vector.x) < .5 else current_knockback_vector / 1.5 

func handle_animation(input_vec : Vector2, vel : Vector2):
	get_global_mouse_position()
	if vel.length() > 0:
		animated_sprite_2d.scale.x = -abs(animated_sprite_2d.scale.x) if input_vec.x < 0 else abs(animated_sprite_2d.scale.x)
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
