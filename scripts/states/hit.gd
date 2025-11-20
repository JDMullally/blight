extends MonsterState
@onready var timer: Timer = %Timer

func enter() -> void:
	if timer:
		timer.stop()
		timer.wait_time = .2
		timer.one_shot = true
		timer.start()
	
func on_tick() -> void:
	if timer.is_stopped():
		transition_requested.emit(self, MonsterState.State.Cooldown, monster)
