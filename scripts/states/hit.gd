extends MonsterState
@onready var timer: Timer

func enter() -> void:
	timer = Timer.new()
	SignalBus.hurt_player.emit(monster.get_damage(), monster.global_position)
	timer.wait_time = .2
	timer.one_shot = true
	#timer.autostart = true
	self.add_child(timer)
	if timer:
		timer.start()
	else:
		transition_requested.emit(self, MonsterState.State.Cooldown, monster)

func exit() -> void:
	timer.queue_free()

func on_tick() -> void:
	if timer.is_stopped():
		transition_requested.emit(self, MonsterState.State.Cooldown, monster)
