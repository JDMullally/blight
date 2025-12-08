extends Node2D
class_name MonsterSpawner

var edge_points : Array[Vector2] = [
	Vector2(-1000, -1850),
	Vector2(-1000, -1657.143),
	Vector2(-1000, -1464.286),
	Vector2(-1000, -1271.429),
	Vector2(-1000, -1078.571),
	Vector2(-1000, -885.714),
	Vector2(-1000, -692.857),
	Vector2(-1000, -500),
	Vector2(1300, -1850),
	Vector2(1300, -1657.143),
	Vector2(1300, -1464.286),
	Vector2(1300, -1271.429),
	Vector2(1300, -1078.571),
	Vector2(1300, -885.714),
	Vector2(1300, -692.857),
	Vector2(1300, -500),
	Vector2(-1000, -500),
	Vector2(-691.429, -500),
	Vector2(-382.857, -500),
	Vector2(0, -500),
	Vector2(332.857, -500),
	Vector2(541.429, -500),
	Vector2(850.0, -500),
	Vector2(1260.0, -500)
]

enum SpawnerType {Frog, Dog, Bird, Flower}
const MONSTER_UID = "uid://b5oqg6hilbih"
@export var max_monsters : int = 5
@export var spawning = false
@export var type : SpawnerType
# var monster_list : Array[Monster] = []
var locked = true
var debuffed = false
var monster_index : int = 0
const FROG_STATS_UID = "uid://chje4u2r1pq2n"
const WOLF_STATS = "uid://cv7hcrod5wvii"
const BIRD_STATS = "uid://cih0oy60nqxpj"
const PLANT_STATS = "uid://0qfd68nm2n7"


@onready var spawn_timer: Timer = $SpawnTimer
@onready var talking_stick_timer: Timer = $TalkingStickTimer
@export var player : Player
@onready var despawned_monster_count = 0

func get_uid() -> String:
	match type:
		SpawnerType.Frog:
			return FROG_STATS_UID
		SpawnerType.Dog:
			return WOLF_STATS
		SpawnerType.Bird:
			return BIRD_STATS
		SpawnerType.Flower:
			return PLANT_STATS
		_:
			return ""

func _ready() -> void:
	SignalBus.unlock_spell.connect(unlock_enemy_type)
	SignalBus.debuff_shrine.connect(debuff_spawner)
	# SignalBus.weaken_enemy.connect()
	spawn_timer.wait_time = 2.0
	spawn_timer.one_shot = true
	spawn_timer.start()
	
	talking_stick_timer.wait_time = .01
	talking_stick_timer.one_shot = true
	talking_stick_timer.start()

func unlock_enemy_type(element : SignalBus.Element):
	if is_right_element(element) and locked:
		locked = false

func is_right_element(element : SignalBus.Element):
	match element:
		SignalBus.Element.Water:
			return type == SpawnerType.Frog
		SignalBus.Element.Love:
			return type == SpawnerType.Dog
		SignalBus.Element.Light:
			return type == SpawnerType.Flower
		SignalBus.Element.Song:
			return type == SpawnerType.Bird
		_:
			return false
			

func disable_monster_spawner():
	despawned_monster_count = 0
	spawning = false

func enable_monster_spawner():
	spawning = true

func get_monster_list() -> Array[Monster]:
	var monster_list : Array[Monster] = []
	var purge_list : Array[Monster] = []
	var kill_list : Array[Monster] = []
	for child in get_children():
		if child is Monster:
			if child.purge_me:
				purge_list.append(child)
			elif child.kill_me:
				kill_list.append(child)
			else:
				monster_list.append(child)
	
	for n in purge_list:
		n.queue_free()
		despawned_monster_count += 1
	
	for n in kill_list:
		var val = randi_range(1, 20)
		if val == 20:
			SignalBus.create_powerup_at_location.emit(n.global_position)
		n.queue_free()
	
	return monster_list

func get_new_spawn_point() -> Vector2:
	edge_points.shuffle()
	return edge_points[0]

func debuff_spawner(shrine_type : SignalBus.Element):
	if shrine_type == SignalBus.Element.Love and type == SpawnerType.Dog:
		debuff()
	elif shrine_type == SignalBus.Element.Water and type == SpawnerType.Frog:
		debuff()
	elif shrine_type == SignalBus.Element.Song and type == SpawnerType.Bird:
		debuff()
	elif shrine_type == SignalBus.Element.Light and type == SpawnerType.Flower:
		debuff()
	else:
		print("Something terribly wrong has occured :(")

func debuff():
	max_monsters = int(float(max_monsters / 3.0))

func _on_spawn_timer_timeout() -> void:
	if !spawning or locked:
		spawn_timer.start()
		return
	var monster_list : Array[Monster] = get_monster_list()
	
	if len(monster_list) < max_monsters:
		var new_monster : Monster = load(MONSTER_UID).instantiate()
		new_monster.monster_stats = load(get_uid()).duplicate(true)
		if type == SpawnerType.Dog:
			new_monster.scale = Vector2(1.5, 1.5)
		var spawn_point = get_new_spawn_point()
		new_monster.global_position = spawn_point
		new_monster.home = spawn_point
		add_child(new_monster)
		if despawned_monster_count > 0:
			despawned_monster_count = clampi(despawned_monster_count - 1, 0, max_monsters)
			spawn_timer.wait_time = .4
		else:
			spawn_timer.wait_time = get_new_wait_time(monster_list)
	spawn_timer.start()

func get_new_wait_time(monster_list : Array[Monster]):
	var new_wait_time =  clampf(len(monster_list) * .4, .4, 2.0)
	return new_wait_time

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
