extends MonsterState

const MELEE_DISTANCE = 16.0
const MAX_RETRIES = 5
@onready var agent : NavigationAgent2D = %NavigationAgent2D
@onready var player : Node2D = get_tree().get_first_node_in_group("player")
var retries = 0
var repath_distance_threshold : float = 32.0
var last_player_target : Vector2 = Vector2.INF

func enter() -> void:
	if player != null:
		monster.modulate.a = 1.0
		_update_agent_target(true)
	monster.talking_stick = true

func on_tick() -> void:
	_move_to_target()
	_hit_player()

func _hit_player():
	var player_pos : Vector2 = player.global_position
	# var player_velocity : Vector2 = player.velocity
	if monster.global_position.distance_to(player_pos) <= monster.attack_range:
		transition_requested.emit(self, MonsterState.State.Hit, monster)

func _move_to_target() -> void:
	var should_move = false
	if monster.talking_stick:
		monster.talking_stick = false
		if player == null:
			return
		should_move = _update_agent_target(false)
	else:
		should_move = true
		
	if player == null:
		return
	
	if agent.is_navigation_finished():
		monster.velocity = Vector2.ZERO
		monster.move_and_slide()
		return
		
	if should_move:
		# print("bye")
		var next_point : Vector2 = agent.get_next_path_position()
		var direction : Vector2 = next_point - monster.global_position
	
		if direction.length() < 1.0:
			monster.move_and_slide()
			return
		
		direction = direction.normalized()
		var player_pos : Vector2 = player.global_position
		var distance_from_player: Vector2  = player_pos - monster.global_position
		# print(abs(distance_from_player.length()))
		monster.flip_to_direction(direction)
		if abs(distance_from_player.length()) > 350:
			monster.velocity = monster.create_velocity_vector(monster.get_speed() * 10, direction)
		else:
			monster.velocity = monster.create_velocity_vector(monster.get_speed(), direction)
	else:
		print("hi")
		monster.velocity = Vector2.ZERO
		
	monster.play_animation()
	monster.move_and_slide()


func get_circle_points(center: Vector2, radius: float, count: int = 16) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i: int in count:
		var angle: float = TAU * float(i) / float(count) # TAU = 2 * PI
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * radius
		points.append(center + offset)
	return points

func _update_agent_target(force : bool) -> bool:
	var player_pos : Vector2 = player.global_position
	var _player_velocity : Vector2 = player.velocity

	monster.play_animation()
	if not force and last_player_target.distance_to(player_pos) < repath_distance_threshold:
		return true
	
	var rad = 14
	var points = get_circle_points(player_pos, rad)
	points.shuffle()
	retries = 0
	var new_pos = points[0] + player.velocity * monster.hunter_time/3
	agent.target_position = new_pos
	last_player_target = new_pos
	
	if !agent.is_target_reachable():
		transition_requested.emit(self, MonsterState.State.Idle, monster)
		monster.velocity = Vector2.ZERO
		monster.play_animation()
		return false
	return true
