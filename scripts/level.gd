extends Node2D

@onready var fps: Label = %FPS
@onready var num_enemies: Label = %NumEnemies
@onready var timer: Timer = %Timer
@onready var frog_spawner: MonsterSpawner = %FrogSpawner
@onready var dog_spawner: MonsterSpawner = %DogSpawner
@onready var bird_spawner: MonsterSpawner = %BirdSpawner
@onready var flower_spawner: MonsterSpawner = %FlowerSpawner

func _ready() -> void:
	fps.text = str(Engine.get_frames_per_second())
	num_enemies.text = str(len(frog_spawner.get_monster_list()))
	timer.start()
	SignalBus.unlock_spell.emit(SignalBus.Element.Light)
	SignalBus.unlock_spell.emit(SignalBus.Element.Love)
	SignalBus.unlock_spell.emit(SignalBus.Element.Song)
	frog_spawner.locked = false
	dog_spawner.locked = true
	bird_spawner.locked = true
	flower_spawner.locked = true

func _on_timer_timeout() -> void:
	timer.start()
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	num_enemies.text = "Total Enemies:" + str(
		len(frog_spawner.get_monster_list()) 
		+ len(dog_spawner.get_monster_list())
		+ len(bird_spawner.get_monster_list())
		+ len(flower_spawner.get_monster_list())
		)


func _on_area_2d_body_entered(_body: Node2D) -> void:
	frog_spawner.disable_monster_spawner()
	dog_spawner.disable_monster_spawner()
	bird_spawner.disable_monster_spawner()
	flower_spawner.disable_monster_spawner()


func _on_area_2d_body_exited(_body: Node2D) -> void:
	frog_spawner.enable_monster_spawner()
	dog_spawner.enable_monster_spawner()
	bird_spawner.enable_monster_spawner()
	flower_spawner.enable_monster_spawner()
