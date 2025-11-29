extends MonsterState

const DAZZLE_MOVESPEED : float = 50.0

func enter():
	if monster != null:
		monster.dazzle_particles.emitting = true
		monster.dazzle_timer.stop()
		monster.dazzle_timer.wait_time = monster.dazzle_duration
		monster.dazzle_timer.start()
		var angle : float = randf() * TAU
		var dir : Vector2 = Vector2(cos(angle), sin(angle))
		monster.flip_to_direction(dir)
		monster.velocity = monster.create_velocity_vector(DAZZLE_MOVESPEED, dir)
		
func on_tick() -> void:
	if monster.dazzle_timer.is_stopped():
		end_dazzle()
		transition_requested.emit(self, MonsterState.State.Idle, monster)
	monster.play_animation()
	monster.move_and_slide()

func end_dazzle():
	monster.dazzle_particles.emitting = false
	monster.velocity = Vector2.ZERO
	monster.play_animation()
	if !monster.dazzle_timer.is_stopped():
		monster.dazzle_timer.stop()

func exit() -> void:
	end_dazzle()
