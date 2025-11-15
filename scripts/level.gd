extends Node2D

const TIMER_LIMIT = .5
var timer = 0.0

func _process(delta : float):
	timer += delta
	if timer > TIMER_LIMIT: 
		timer = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))
