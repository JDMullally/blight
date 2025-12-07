extends Panel
class_name StatChart

@onready var potentency: ProgressBar = $Potentency
@onready var power: ProgressBar = $Power
@onready var effectiveness: ProgressBar = $Effectiveness
@onready var difficulty: ProgressBar = $Difficulty
@onready var rapidity: ProgressBar = $Rapidity


func update_values(damage : float, pierce : float, speed : float, debuff : float, cooldown : float):
	potentency.value = debuff
	power.value = damage
	effectiveness.value = pierce
	difficulty.value = cooldown
	rapidity.value = speed
	# print(debuff, " ", damage, " ", pierce, " ", cooldown, " ", speed)
