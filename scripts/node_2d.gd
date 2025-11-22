extends Node2D
class_name MonsterSpawner

const MONSTER_UID = "uid://b5oqg6hilbih"
@export var max_monsters : int = 5

# var monster_list : Array[Monster] = []
var monster_index : int = 0

@onready var spawn_timer: Timer = $SpawnTimer
@onready var talking_stick_timer: Timer = $TalkingStickTimer
@export var player : Player

func _ready() -> void:
	spawn_timer.wait_time = 1.0
	spawn_timer.one_shot = true
	spawn_timer.start()
	
	talking_stick_timer.wait_time = .01
	talking_stick_timer.one_shot = true
	talking_stick_timer.start()

func get_monster_list() -> Array[Monster]:
	var monster_list : Array[Monster] = []
	var purge_list : Array[Monster] = []
	
	for child in get_children():
		if child is Monster:
			if child.purge_me:
				purge_list.append(child)
			else:
				monster_list.append(child)
	
	for n in purge_list:
		n.queue_free()
	return monster_list

func _on_spawn_timer_timeout() -> void:
	var monster_list : Array[Monster] = get_monster_list()
	
	if len(monster_list) < max_monsters:
		var new_monster = load(MONSTER_UID).instantiate()
		new_monster.scale = Vector2(0.5,0.5)
		var x_sign : int = -1 if (randi() % 2 == 0) else 1
		var y_sign : int = -1 if (randi() % 2 == 0) else 1
		var spawn_point : Vector2 = Vector2(player.global_position.x + 300 * x_sign, player.global_position.y + 300 * y_sign)
		new_monster.global_position = spawn_point
		new_monster.home = spawn_point
		add_child(new_monster)
		spawn_timer.wait_time = get_new_wait_time(monster_list)
	spawn_timer.start()


func get_new_wait_time(monster_list : Array[Monster]):
	return clampf(len(monster_list) * .05, .1, 1.0)

func _on_talking_stick_timer_timeout() -> void:
	talking_stick_timer.start()
	var monster_list = get_monster_list()
	if len(monster_list) > 0:
		monster_index = clampi(monster_index, 0, len(monster_list) - 1)
		var current_monster : Monster = monster_list[monster_index]
		if current_monster:
			current_monster.get_talking_stick(get_new_wait_time(monster_list))
		monster_index = clampi((monster_index + 1) % len(monster_list), 0, len(monster_list) - 1)
	else:
		monster_index = 0
