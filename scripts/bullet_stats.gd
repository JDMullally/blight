extends Resource
class_name BulletStats

const BASE_DAMAGE : int = 5
const BASE_PIERCE : int = 1
const MAX_PIERCE : int = 25
const BASE_SPEED : float = 250.0

@export var element : SignalBus.Element = SignalBus.Element.Water
@export var damage : int = 5
@export var num_pierce : int = 1
@export var speed : float = 300.0

func update_stats(percentage : float, given_element : SignalBus.Element):
	speed = clampf((1 - percentage) * BASE_SPEED, BASE_SPEED / 8.0, BASE_SPEED)
	element = given_element
	num_pierce = clampi(int(MAX_PIERCE * percentage), BASE_PIERCE, MAX_PIERCE)
	damage = clampi(int(BASE_DAMAGE / percentage), BASE_DAMAGE, BASE_DAMAGE * 12)
	
	print(SignalBus.Element.find_key(element), " ", speed, " ", num_pierce," ", damage)

func decrement_hits():
	num_pierce = num_pierce - 1

func hits_spent():
	return num_pierce <= 0
