extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Paused.hide()

func _input(event: InputEvent) -> void:
	
	#Pause menu event handler
	if event.is_action_pressed("pause") and !get_tree().paused:
		$Paused.show()
		get_tree().paused = true
	elif event.is_action_pressed("pause") and get_tree().paused:
		$Paused.hide()
		get_tree().paused = false
