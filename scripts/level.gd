extends Node2D

@onready var fps: Label = %FPS
@onready var num_enemies: Label = %NumEnemies
@onready var timer: Timer = %Timer
@onready var frog_spawner: MonsterSpawner = %FrogSpawner
@onready var dog_spawner: MonsterSpawner = %DogSpawner
@onready var bird_spawner: MonsterSpawner = %BirdSpawner
@onready var flower_spawner: MonsterSpawner = %FlowerSpawner
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var completed_shrines : int = 0

func _ready() -> void:
	background_music.play()
	SignalBus.complete_shrine.connect(complete_shrine)
	SignalBus.game_over_screen.connect(game_over)
	fps.text = str(Engine.get_frames_per_second())
	num_enemies.text = str(len(frog_spawner.get_monster_list()))
	timer.start()
	frog_spawner.locked = false

func complete_shrine():
	completed_shrines += 1	
	if completed_shrines >= 2:
		game_win()

func game_over():
	get_tree().change_scene_to_file("res://scenes/Lose_screen.tscn")
	
func game_win():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

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


func _on_background_music_finished() -> void:
	background_music.play(60.0)
