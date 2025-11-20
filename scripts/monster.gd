extends CharacterBody2D
class_name Monster

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var timer : Timer = $Timer
@onready var player : Node2D = get_tree().get_first_node_in_group("player")

var speed : float = 120.0
var repath_distance_threshold : float = 32.0
var last_player_target : Vector2 = Vector2.INF


func _ready() -> void:
	pass
