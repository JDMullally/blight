extends MonsterState

func enter():
	if monster != null:
		monster.dissapear()
