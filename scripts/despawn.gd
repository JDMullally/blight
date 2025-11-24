extends MonsterState

func enter():
	if monster != null:
		monster.velocity = Vector2.ZERO
		monster.play_animation()
		monster.dissapear()
