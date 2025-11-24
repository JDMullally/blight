extends Resource
class_name MonsterStats

const max_hitpoints : int = 15
@export var hitpoints : int = max_hitpoints
@export var damage : int = 5
@export var speed : int = 100
@export var affinity : SignalBus.Element = SignalBus.Element.Water
@export var stat_multiplier : float =  1.0

func take_damage(damage_taken : int):
	hitpoints = hitpoints - damage_taken

func is_dead() -> bool:
	return hitpoints <= 0
