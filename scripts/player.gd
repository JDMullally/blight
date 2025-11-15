extends CharacterBody2D
class_name Player

const VELOCITY : int = 150
var input_vector : Vector2 = Vector2.ZERO

@onready var wand: Node2D = $Wand

func _physics_process(_delta: float) -> void:
	input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_vector * VELOCITY
	move_and_slide()
	
