extends MonsterState

@onready var timer: Timer = %Timer

func enter():
	timer.stop()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.start()
	monster.velocity = Vector2.ZERO
	monster.play_animation()

func on_tick():
	if timer.is_stopped():
		transition_requested.emit(self, MonsterState.State.Idle, monster)
