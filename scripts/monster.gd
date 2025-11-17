extends CharacterBody2D

@export var speed : float = 200.0

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Player = get_tree().get_first_node_in_group("player") as Player
@onready var timer: Timer = $Timer

func _ready() -> void:
	if player != null:
		agent.target_position = player.global_position
	timer.start()

func _physics_process(_delta : float) -> void:
	move_to_target()

func move_to_target():
	if player == null:
		return
	
	if !agent.is_target_reachable():
		agent.target_position = Vector2(0,0)
	
	
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var next_point : Vector2 = agent.get_next_path_position()
	var direction : Vector2 = (next_point - self.global_position).normalized()
		
	velocity = direction * speed
	move_and_slide()

func _on_timer_timout():
	if agent.target_position != player.global_position:
		agent.target_position = player.global_position
	timer.start()
