extends Node2D

@onready var frog_spawner: MonsterSpawner = %FrogSpawner
@onready var dog_spawner: MonsterSpawner = %DogSpawner
@onready var bird_spawner: MonsterSpawner = %BirdSpawner
@onready var flower_spawner: MonsterSpawner = %FlowerSpawner
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var completed_shrines : int = 0
@onready var gauntlet_timer : Timer
@onready var grove_block_off_collision: StaticBody2D = %GroveBlockOffCollision
@onready var grove_collision: CollisionPolygon2D = %GroveCollision
@onready var gpu_particles_2d: GPUParticles2D = $Gauntlet/GPUParticles2D
@onready var texture_progress_bar: SurviveBar = %TextureProgressBar
const POWER_UP = "uid://cutbq3a0oj5q"

func _ready() -> void:
	gauntlet_timer = Timer.new()
	gauntlet_timer.wait_time = 60.0
	gauntlet_timer.one_shot = true
	gauntlet_timer.timeout.connect(game_win)
	add_child(gauntlet_timer)
	
	background_music.play()
	SignalBus.complete_shrine.connect(complete_shrine)
	SignalBus.game_over_screen.connect(game_over)
	SignalBus.create_powerup_at_location.connect(create_powerup_at_location)
	dog_spawner.locked = false
	# SignalBus.unlock_spell.emit(SignalBus.Element.Song)
	
func complete_shrine():
	completed_shrines += 1
	if completed_shrines >= 3:
		gauntlet()

func gauntlet():
	gauntlet_timer.start()
	grove_block_off_collision.set_collision_layer_value(1, true)
	grove_block_off_collision.set_collision_layer_value(2, true)
	grove_block_off_collision.set_collision_mask_value(1, true)
	grove_block_off_collision.set_collision_mask_value(2, true)
	gpu_particles_2d.emitting = true
	texture_progress_bar.show_bar()

func _process(_delta: float) -> void:
	if !gauntlet_timer.is_stopped():
		SignalBus.update_survival_bar.emit(gauntlet_timer.time_left / gauntlet_timer.wait_time)

func game_over():
	get_tree().change_scene_to_file("res://scenes/Lose_screen.tscn")
	
func game_win():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func create_powerup_at_location(global_pos : Vector2):
	var new_power_up = load(POWER_UP).instantiate() as PowerUp
	new_power_up.global_position = global_pos
	add_child(new_power_up)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	SignalBus.increase_player_healing.emit(4)
	SignalBus.allow_spell_crafting.emit()
	frog_spawner.disable_monster_spawner()
	dog_spawner.disable_monster_spawner()
	bird_spawner.disable_monster_spawner()
	flower_spawner.disable_monster_spawner()


func _on_area_2d_body_exited(_body: Node2D) -> void:
	SignalBus.reduce_player_healing.emit()
	SignalBus.stop_spell_crafting.emit()
	frog_spawner.enable_monster_spawner()
	dog_spawner.enable_monster_spawner()
	bird_spawner.enable_monster_spawner()
	flower_spawner.enable_monster_spawner()


func _on_background_music_finished() -> void:
	background_music.play(60.5)
