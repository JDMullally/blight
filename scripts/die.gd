extends MonsterState

func enter():
	if monster != null:
		monster.velocity = Vector2.ZERO
		monster.animated_sprite_2d.play("cured")
		monster.die()
		# DISABLE HITBOX
		# CHOOSE A RANDOM DIRECTION
		
func on_tick() -> void:
	pass
	# Update velocity and move in random direction
