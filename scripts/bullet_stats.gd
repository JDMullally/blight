extends Resource
class_name BulletStats

const BASE_DAMAGE : int = 5
const BASE_PIERCE : int = 1
const MAX_PIERCE : int = 25
const BASE_SPEED : float = 300.0
const BASE_DEBUFF_TIME : float = 2.0
const MIN_COOLDOWN : float = 1.0
const MAX_COOLDOWN : float = 3.0
const MAX_EFFECTIVE_DAMAGE : float = 50.0


@export var element : SignalBus.Element = SignalBus.Element.Water
@export var damage : int = 5
@export var num_pierce : int = 1
@export var speed : float = 300.0
@export var debuff_time : float = 1.0
@export var cooldown : float = 1.0

func update_stats(percentage : float, given_element : SignalBus.Element):
	speed = clampf((1 - percentage) * BASE_SPEED, BASE_SPEED / 6.0, BASE_SPEED)
	element = given_element
	num_pierce = clampi(int(MAX_PIERCE * percentage), BASE_PIERCE, MAX_PIERCE)
	damage = clampi(int(BASE_DAMAGE / percentage), BASE_DAMAGE, BASE_DAMAGE * 12)
	debuff_time = clampf((1 - percentage) * BASE_DEBUFF_TIME, 0.1, BASE_DEBUFF_TIME)
	var cooldown_modifier = float(damage * num_pierce) / MAX_EFFECTIVE_DAMAGE
	cooldown = clampf(cooldown_modifier * MIN_COOLDOWN, MIN_COOLDOWN, MAX_COOLDOWN)
	#SignalBus.update_book_stats(element, speed, num_pierce, damage, debuff_time, cooldown)
	print(
		SignalBus.Element.find_key(element),
		"\nspeed: ",
		scale_to_range(speed, BASE_SPEED/6.0, BASE_SPEED),
		"\npierce: ",
		scale_to_range(float(num_pierce), BASE_PIERCE, MAX_PIERCE),
		"\ndamage: ",
		scale_to_range(float(damage), BASE_DAMAGE, BASE_DAMAGE * 12),
		"\ndebuff: ",
		scale_to_range(debuff_time, 0.1, BASE_DEBUFF_TIME),
		"\ncooldown: ",
		scale_to_range(cooldown, MAX_COOLDOWN, MIN_COOLDOWN))


func scale_to_range(value : float, in_min : float, in_max : float, out_min = 1.0, out_max = 15.0) -> float:
	var t : float = clamp((value - in_min) / (in_max - in_min), 0.0, 1.0)
	return lerp(out_min, out_max, t)

func decrement_hits():
	num_pierce = num_pierce - 1

func hits_spent():
	return num_pierce <= 0
