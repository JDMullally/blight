extends MonsterState

const MELEE_DISTANCE = 16.0

@onready var agent : NavigationAgent2D = %NavigationAgent2D
@onready var player : Node2D = get_tree().get_first_node_in_group("player")

var repath_distance_threshold : float = 32.0
var last_player_target : Vector2 = Vector2.INF

func enter() -> void:
	if player != null:
		_update_agent_target(true)
	monster.talking_stick = true
	#if timer != null:
		#timer.start(randf_range(0.0, timer.wait_time))

func on_tick() -> void:
	_move_to_target()

func _move_to_target() -> void:
	if monster.talking_stick:
		monster.talking_stick = false
		if player == null:
			return
		_update_agent_target(false)
	
	if player == null:
		return
	
	if agent.is_navigation_finished():
		monster.velocity = Vector2.ZERO
		monster.move_and_slide()
		return
	
	var next_point : Vector2 = agent.get_next_path_position()
	var direction : Vector2 = next_point - monster.global_position
	
	if direction.length() < 1.0:
		monster.move_and_slide()
		return
	
	direction = direction.normalized()
	
	monster.flip_to_direction(direction)
	
	monster.velocity = direction * monster.speed
	monster.play_animation()
	monster.move_and_slide()


func _update_agent_target(force : bool) -> void:
	var player_pos : Vector2 = player.global_position
	if monster.global_position.distance_to(player_pos) <= monster.attack_range:
		transition_requested.emit(self, MonsterState.State.Hit, monster)
		return
		
	if !agent.is_target_reachable():
		transition_requested.emit(self, MonsterState.State.Despawn, monster)
		agent.target_position = monster.home
		return
	
	if not force and last_player_target.distance_to(player_pos) < repath_distance_threshold:
		return
	agent.target_position = player_pos
	last_player_target = player_pos
