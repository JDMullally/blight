extends CharacterBody2D
class_name Monster

const KNOCKBACK : float = 250.0
@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var timer : Timer = $Timer
@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var state_machine: StateMachine = $StateMachine
@onready var idle: Node = $StateMachine/Idle
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon_2d: CollisionShape2D = $CollisionPolygon2D
@onready var purge_me = false
@onready var kill_me = false
@onready var dazzle_particles: GPUParticles2D = $DazzleParticles
@onready var stun_particles: GPUParticles2D = $StunParticles
@onready var hurt_noise: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var monster_stats : MonsterStats

var current_knockback_vector : Vector2 = Vector2.ZERO
var impulse_decay_timer : Timer
var slow_timer : Timer
var dazzle_timer : Timer
var stun_timer : Timer
var slow_multiplier : float = 1.0
var slow_duration : float = 1.0
var dazzle_duration : float = 1.0
var knockback_value : float = KNOCKBACK
var stun_duration : float = 1.0
var skew_tween : Tween
var home : Vector2 = Vector2.ZERO
var talking_stick : bool = true
var hunter_time : float = 0.0
var repath_distance_threshold : float = 32.0
var last_player_target : Vector2 = Vector2.INF
var attack_range : float  = 16.0

func apply_impulse(dir : Vector2):
	current_knockback_vector = current_knockback_vector + knockback_value * dir

func decay_knockback():
	if impulse_decay_timer.is_stopped():
		impulse_decay_timer.start()
		current_knockback_vector = Vector2.ZERO if abs(current_knockback_vector.x) < .5 else current_knockback_vector / 1.5 


func get_speed() -> float:
	return monster_stats.speed * monster_stats.stat_multiplier

func get_damage() -> int:
	return int(monster_stats.damage * monster_stats.stat_multiplier)

func get_talking_stick(time : float):
	hunter_time = time
	talking_stick = true

func apply_slow():
	self.modulate.g8 = 180
	self.modulate.r8 = 0
	self.modulate.b8 = 255
	slow_timer.wait_time = slow_duration
	slow_multiplier = .5
	slow_timer.start()

func apply_affix(element : SignalBus.Element, debuff_multiplier : float):
	if state_machine.current_state.state == MonsterState.State.Dead:
		return
	match element:
		SignalBus.Element.Water:
			slow_duration = debuff_multiplier
			apply_slow()
		SignalBus.Element.Song:
			knockback_value = KNOCKBACK * debuff_multiplier
			knockback_from_player()
		SignalBus.Element.Love:
			stun_duration = debuff_multiplier / 2
			state_machine.stun()
		SignalBus.Element.Light:
			dazzle_duration = debuff_multiplier / 1.5
			state_machine.dazzle()
		_:
			print("something went terribly wrong!")

func _ready() -> void:
	dazzle_particles.emitting = false
	stun_particles.emitting = false
	dazzle_timer = Timer.new()
	dazzle_timer.wait_time = 1.0
	dazzle_timer.one_shot = true
	add_child(dazzle_timer)
	
	stun_timer = Timer.new()
	stun_timer.wait_time = 1.0
	stun_timer.one_shot = true
	add_child(stun_timer)
	
	slow_timer = Timer.new()
	slow_timer.wait_time = 1.0
	slow_timer.one_shot = true
	add_child(slow_timer)
	
	impulse_decay_timer = Timer.new()
	impulse_decay_timer.wait_time = .1
	impulse_decay_timer.one_shot = true
	add_child(impulse_decay_timer)
	
	state_machine.initial_state = idle
	if monster_stats:
		animated_sprite_2d.sprite_frames = monster_stats.sprite_frames
		collision_polygon_2d.shape = monster_stats.hitbox_shape
		collision_polygon_2d.position = monster_stats.hitbox_position
	else:
		monster_stats = MonsterStats.new()

func resolve_slow():
	if slow_timer.is_stopped():
		slow_multiplier = 1.0
		self.modulate.g8 = 255
		self.modulate.r8 = 255
		self.modulate.b8 = 255

func _physics_process(_delta: float) -> void:
	decay_knockback()
	resolve_slow()

func create_velocity_vector(speed : float, dir : Vector2) -> Vector2:
	return slow_multiplier * (speed * dir) + current_knockback_vector

func flip_to_direction(direction : Vector2):
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	if direction.x < 0:
		animated_sprite_2d.flip_h = true

func knockback_from_player():
	apply_impulse((self.global_position - player.global_position).normalized())

func take_damage(damage : int):
	monster_stats.take_damage(damage)
	hurt_noise.play()
	# print(monster_stats.hitpoints)
	if skew_tween and skew_tween.is_valid():
		skew_tween.kill()
		
	skew_tween = get_tree().create_tween()
	
	skew_tween.tween_property(self, "skew", 1, 0.1)
	skew_tween.tween_property(self, "skew", -1, 0.2)
	skew_tween.tween_property(self, "skew", 0.0, 0.1)
	
	if monster_stats.is_dead():
		# print('im dead!')
		state_machine.set_kill_state()
	
func play_animation():
	if velocity.length() > 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func dissapear():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): 
		purge_me = true
	)

func die():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): 
		kill_me = true)
