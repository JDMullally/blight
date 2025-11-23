extends CharacterBody2D
class_name Player

const VELOCITY : int = 100

var input_vector : Vector2 = Vector2.ZERO
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wand: Node2D = $Wand

func _physics_process(_delta: float) -> void:
	input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_vector * VELOCITY
	handle_animation(input_vector, velocity)
	move_and_slide()
	
func handle_animation(input_vec : Vector2, vel : Vector2):
	if vel.length() > 0:
		animated_sprite_2d.scale.x = -abs(animated_sprite_2d.scale.x) if input_vec.x < 0 else abs(animated_sprite_2d.scale.x)
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
