extends Node2D

@onready var wisp_1: Wisp = $Wisp
@onready var wisp_2: Wisp = $Wisp2
@onready var wisp_3: Wisp = $Wisp3
@onready var wisps = [wisp_1, wisp_3, wisp_2]
@onready var wand : Wand = get_tree().get_first_node_in_group("wand")
@onready var wisp_tracking_dict : Dictionary= {}
@onready var tracked_monsters : Array[Monster] = []
var timer : Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = .2
	timer.timeout.connect(fire_bullets)
	self.add_child(timer)
	timer.start()
	
	set_wisp_colors_and_visible()
	SignalBus.select_spell.connect(update_wisps)
	SignalBus.unlock_spell.connect(update_wisps)

func update_wisps(_element : SignalBus.Element):
	wisp_tracking_dict = {}
	set_wisp_colors_and_visible()
	# print(wisp_tracking_dict)

func fire_bullets():
	for key in wisp_tracking_dict.keys():
		if wand.is_spell_ready(key) and len(tracked_monsters) > 0:
			var random_index = randi_range(0, len(tracked_monsters) - 1)
			var monster : Monster = tracked_monsters[random_index]
			wand.gen_bullet(key, wisp_tracking_dict[key].global_position, monster.global_position - wisp_tracking_dict[key].global_position, true)
	if timer:
		timer.start()

func hide_all_wisps():
	for wisp in wisps:
		wisp.hide_wisp()

func set_wisp_colors_and_visible():
	hide_all_wisps()
	var wisp_index = 0
	var current_spell = wand.current_element
	for spell in wand.unlocked_spells:
		if spell != SignalBus.Element.find_key(current_spell):
			var wisp : Wisp = wisps[wisp_index]
			wisp.element = SignalBus.Element[spell]
			wisp_tracking_dict[wisp.element] = wisp
			wisp.set_light_color()
			wisp.show_wisp()
			wisp_index = clampi(wisp_index + 1, 0, 2)
		# print("hi!")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Monster:
		tracked_monsters.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Monster:
		tracked_monsters.remove_at(tracked_monsters.find(body))
