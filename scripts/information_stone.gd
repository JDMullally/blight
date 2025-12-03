extends Sprite2D
class_name InformationStone

@export var information : String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalBus.update_player_text.emit(information)
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		SignalBus.update_player_text.emit("")
