extends Node2D

@onready var fps: Label = %FPS
@onready var num_enemies: Label = %NumEnemies
@onready var timer: Timer = %Timer
@onready var monster_spawner: MonsterSpawner = $MonsterSpawner

func _ready() -> void:
	fps.text = str(Engine.get_frames_per_second())
	num_enemies.text = str(len(monster_spawner.get_monster_list()))
	timer.start()


func _on_timer_timeout() -> void:
	timer.start()
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	num_enemies.text = "Total Enemies:" + str(len(monster_spawner.get_monster_list()))
