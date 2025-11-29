extends MonsterState

func enter():
	if monster != null:
		monster.stun_particles.emitting = true
		monster.stun_timer.stop()
		monster.stun_timer.wait_time = monster.stun_duration
		monster.stun_timer.start()
		monster.velocity = Vector2.ZERO
		monster.play_animation()
		
func on_tick() -> void:
	if monster.stun_timer.is_stopped():
		monster.stun_particles.emitting = false
		transition_requested.emit(self, MonsterState.State.Idle, monster)
		monster.velocity = Vector2.ZERO
		monster.play_animation()

func end_stun():
	monster.stun_particles.emitting = false
	monster.velocity = Vector2.ZERO
	monster.play_animation()
	if !monster.stun_timer.is_stopped():
		monster.stun_timer.stop()
