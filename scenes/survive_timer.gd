extends TextureProgressBar
class_name SurviveBar

@onready var timer : Timer
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready():
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): rich_text_label.hide())
	SignalBus.update_survival_bar.connect(update_survival_value)

func show_bar():
	self.show()
	timer.start()

func update_survival_value(new_value : float):
	self.value = new_value
