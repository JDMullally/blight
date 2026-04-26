extends Panel
class_name StatChart

@onready var disable_bar: ProgressBar = %Disable
@onready var healing_power_bar: ProgressBar = %HealingPower
@onready var cooldown_bar: ProgressBar = %Cooldown
@onready var speed_bar: ProgressBar = %Speed
@onready var pierce_bar: ProgressBar = %Pierce

@onready var healing_power_sprite: TextureRect = %HealingPowerSprite
@onready var pierce_sprite: TextureRect = %PierceSprite
@onready var cooldown_sprite: TextureRect = %CooldownSprite
@onready var speed_sprite: TextureRect = %SpeedSprite
@onready var disable_sprite: TextureRect = %DisableSprite
@onready var mouse_over: RichTextLabel = $MouseOver

func _ready():
	healing_power_sprite.mouse_entered.connect(func(): mouse_over.append_text("Healing Power\n"))
	pierce_sprite.mouse_entered.connect(func(): mouse_over.append_text("Piercing\n"))
	cooldown_sprite.mouse_entered.connect(func(): mouse_over.append_text("Cooldown\n"))
	speed_sprite.mouse_entered.connect(func(): mouse_over.append_text("Projectile Speed\n"))
	disable_sprite.mouse_entered.connect(func(): mouse_over.append_text("Disable Duration\n"))
	healing_power_sprite.mouse_exited.connect(clear_text)
	pierce_sprite.mouse_exited.connect(clear_text)
	cooldown_sprite.mouse_exited.connect(clear_text)
	speed_sprite.mouse_exited.connect(clear_text)
	disable_sprite.mouse_exited.connect(clear_text)
	
func clear_text():
	mouse_over.clear()

func update_values(damage : float, pierce : float, speed : float, debuff : float, cooldown : float):
	disable_bar.value = debuff
	healing_power_bar.value = damage
	pierce_bar.value = pierce
	cooldown_bar.value = cooldown
	speed_bar.value = speed
