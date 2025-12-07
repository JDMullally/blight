extends Area2D
class_name PowerUp

const COOLDOWN_TIMER = preload("uid://bcv3pf1q2nf41")
const HEALING = preload("uid://cqqn1t1h65xur")
enum PowerUpType {Heal, AttackSpeed}
@onready var power_up_type : PowerUpType
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	var num = randi_range(0, 1)
	if num == 0:
		sprite_2d.texture = HEALING
		power_up_type = PowerUpType.Heal
	else:
		sprite_2d.texture = COOLDOWN_TIMER
		power_up_type = PowerUpType.AttackSpeed
		

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player : Player = body as Player
		if power_up_type == PowerUpType.Heal:
			player.heal(25)
		elif power_up_type == PowerUpType.AttackSpeed:
			player.increase_attack_speed()
		self.queue_free()
