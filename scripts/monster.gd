extends CharacterBody2D
class_name Monster

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var timer : Timer = $Timer
@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var state_machine: StateMachine = $StateMachine
@onready var idle: Node = $StateMachine/Idle
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var home : Vector2 = Vector2.ZERO
var talking_stick : bool = true
var speed : float = 140.0
var repath_distance_threshold : float = 32.0
var last_player_target : Vector2 = Vector2.INF
var attack_range : float  = 16.0

func _ready() -> void:
	state_machine.initial_state = idle

func flip_to_direction(direction : Vector2):
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	if direction.x < 0:
		animated_sprite_2d.flip_h = true

func play_animation():
	if velocity.length() > 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func dissapear():
	#velocity = Vector2.ZERO
	#animated_sprite_2d.play("idle")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): 
		queue_free()
	)
