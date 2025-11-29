extends MonsterState
@onready var timer: Timer = %Timer

func enter() -> void:
	if timer:
		SignalBus.hurt_player.emit(monster.get_damage(), monster.global_position)
		timer.stop()
		timer.wait_time = .2
		timer.one_shot = true
		timer.start()
	
func on_tick() -> void:
	if timer.is_stopped():
		transition_requested.emit(self, MonsterState.State.Cooldown, monster)
