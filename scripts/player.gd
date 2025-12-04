extends CharacterBody2D
class_name Player

const SPEED : int = 100
const KNOCKBACK : int = 200
const MAX_HP : int = 100
var current_knockback_vector : Vector2 = Vector2.ZERO
var input_vector : Vector2 = Vector2.ZERO
var impulse_decay_timer : Timer

@onready var invulnerability_timer: Timer = $Invulnerability_Timer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var hitpoints = MAX_HP
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wand: Node2D = $Wand
@onready var regen_timer: Timer = %RegenTimer
@onready var walking: AudioStreamPlayer = $Walking
@onready var hit: AudioStreamPlayer = $Hit
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func apply_impulse(dir : Vector2):
	current_knockback_vector = current_knockback_vector + KNOCKBACK * dir

func _ready() -> void:
	gpu_particles_2d.emitting = false
	SignalBus.hurt_player.connect(hit_player)
	invulnerability_timer.timeout.connect(hide_particles)
	impulse_decay_timer = Timer.new()
	impulse_decay_timer.wait_time = .05
	impulse_decay_timer.one_shot = true
	add_child(impulse_decay_timer)
	handle_animation(Vector2.ZERO, Vector2.ZERO)
	regen_timer.start()

func hide_particles():
	gpu_particles_2d.emitting = false

func move_player(_delta : float):
	input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = input_vector * SPEED + Vector2(current_knockback_vector.x, current_knockback_vector.y)
	if velocity == Vector2.ZERO:
		walking.stop()
	elif velocity != Vector2.ZERO and !walking.playing:
		walking.play()
		
	handle_animation(input_vector, velocity)
	decay_knockback()
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_actiodn_pressed("dash") and dash_cooldown_timer.is_stopped():
		dash()

func dash():
	gpu_particles_2d.emitting = true
	var direction = velocity.normalized()
	gpu_particles_2d.scale.x = -1 if direction.x < 0 else 1
	velocity = direction * KNOCKBACK * 2
	invulnerability_timer.start()
	dash_cooldown_timer.start()
	handle_animation(direction, Vector2.ZERO)

func _physics_process(_delta: float) -> void:
	if invulnerability_timer.is_stopped():
		move_player(_delta)
	else:
		move_and_slide()

func hit_player(monster_damage : int, monster_global_position : Vector2):
	if !invulnerability_timer.is_stopped():
		return
	hit.play()
	apply_impulse((self.global_position - monster_global_position).normalized())
	hitpoints = hitpoints - monster_damage
	SignalBus.update_player_health.emit(hitpoints)
	if hitpoints < 0:
		SignalBus.game_over_screen.emit()

func decay_knockback():
	if impulse_decay_timer.is_stopped():
		impulse_decay_timer.start()
		current_knockback_vector = Vector2.ZERO if abs(current_knockback_vector.x) < .5 else current_knockback_vector / 1.5 

func handle_animation(input_vec : Vector2, vel : Vector2):
	# get_global_mouse_position()
	if vel.length() > 0:
		var x_scale = -abs(animated_sprite_2d.scale.x) if input_vec.x < 0 else abs(animated_sprite_2d.scale.x)
		animated_sprite_2d.scale.x = x_scale
		gpu_particles_2d.scale.x = x_scale
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
	else:
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")

func _on_regen_timer_timeout() -> void:
	hitpoints = clampi(hitpoints + 1, -MAX_HP, MAX_HP)
	SignalBus.update_player_health.emit(hitpoints)
	regen_timer.start()
