extends MonsterState

@onready var agent : NavigationAgent2D = %NavigationAgent2D
@onready var timer : Timer = %Timer
@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var aggro_radius : float = 2000.0
@onready var max_distance : float = 4000.0

func enter() -> void:
	if player != null and monster != null:
		monster.modulate.a = 1.0
		check_aggro_radius()
	
	if timer != null:
		timer.wait_time = randf_range(.4, .6)
		timer.one_shot = true
		timer.start(randf_range(0.0, timer.wait_time))
	
func check_aggro_radius() -> void:
	if timer.is_stopped():
		timer.start()
		var player_pos : Vector2 = player.global_position
		var actual_distance = player_pos.distance_to(monster.global_position)
		# print(monster, actual_distance)
		if actual_distance <= aggro_radius:
			transition_requested.emit(self, MonsterState.State.Chase, monster)
		elif actual_distance < max_distance:
			timer.wait_time = randf_range(2.0, 3.0)
		else:
			return
			

func on_tick():
	check_aggro_radius()
