extends Node2D
class_name Wand

const BULLET_SCENE_UID : String = "uid://dkg2e45s87qw0"

@onready var firing = false
@onready var spellbook : Dictionary = {}
@onready var current_element : SignalBus.Element = SignalBus.Element.Love
@onready var wand_sprite : Sprite2D = $WandSprite
@onready var wand_point: Node2D = $WandSprite/WandPoint
@onready var unlocked_spells : Array[String] = []
@onready var water_spell_timer: Timer = %WaterSpellTimer
@onready var love_spell_timer: Timer = %LoveSpellTimer
@onready var light_spell_timer: Timer = %LightSpellTimer
@onready var song_spell_timer: Timer = %SongSpellTimer
@onready var wand_light: PointLight2D = $WandSprite/WandPoint/WandLight


func update_current_element(new_element : SignalBus.Element):
	if SignalBus.Element.find_key(new_element) in spellbook.keys():
		match new_element:
			SignalBus.Element.Water:
				wand_light.color = Color("2b67cb")
			SignalBus.Element.Love:
				wand_light.color = Color("ff88ba")
			SignalBus.Element.Light:
				wand_light.color = Color("ffecbf")
			SignalBus.Element.Song:
				wand_light.color = Color("cbae98")
		
		current_element = new_element

func unlock_spell(element : SignalBus.Element):
	var new_bullet_poly = PackedVector2Array()
	new_bullet_poly.append(Vector2.ZERO)
	new_bullet_poly.append(Vector2(75, -50))
	new_bullet_poly.append(Vector2(150, 0))
	new_bullet_poly.append(Vector2(75, 50))
	new_bullet_poly.append(Vector2.ZERO)
	unlocked_spells.append(SignalBus.Element.find_key(element))
	update_bullet_poly(new_bullet_poly, .05, element)
	
func _ready() -> void:
	SignalBus.unlock_spell.connect(unlock_spell)
	SignalBus.select_spell.connect(update_current_element)
	SignalBus.update_poly.connect(update_bullet_poly)
	SignalBus.scroll_up.connect(scroll_up)
	SignalBus.scroll_down.connect(scroll_down)
	update_current_element(SignalBus.Element.Love)
	unlock_spell(SignalBus.Element.Love)
	current_element = SignalBus.Element.Love

func _process(_delta : float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var to_mouse : Vector2 = mouse_pos - global_position
	rotation = to_mouse.angle()
	send_wand_progress()
	if firing:
		fire_bullet()

func scroll_down():
	var spells_to_check = get_next_order()
	spells_to_check.reverse()
	for spell in spells_to_check:
		if SignalBus.Element.find_key(spell) in unlocked_spells:
			SignalBus.select_spell.emit(spell)

func scroll_up():
	var spells_to_check = get_next_order()
	print(spells_to_check)
	for spell in spells_to_check:
		if SignalBus.Element.find_key(spell) in unlocked_spells:
			SignalBus.select_spell.emit(spell)

func get_next_order() -> Array[SignalBus.Element]:
	match current_element:
		SignalBus.Element.Water:
			return [SignalBus.Element.Light, SignalBus.Element.Song, SignalBus.Element.Love]
		SignalBus.Element.Love:
			return [SignalBus.Element.Water, SignalBus.Element.Light, SignalBus.Element.Song]
		SignalBus.Element.Light:
			return [SignalBus.Element.Song, SignalBus.Element.Love, SignalBus.Element.Water]
		SignalBus.Element.Song:
			return [SignalBus.Element.Love, SignalBus.Element.Water, SignalBus.Element.Light]
		_:
			return []
	
	

func is_spell_ready(ele : SignalBus.Element) -> bool:
	match ele:
		SignalBus.Element.Water:
			return water_spell_timer.is_stopped()
		SignalBus.Element.Love:
			return love_spell_timer.is_stopped()
		SignalBus.Element.Light:
			return light_spell_timer.is_stopped()
		SignalBus.Element.Song:
			return song_spell_timer.is_stopped()
		_:
			return false

func trigger_cooldown(ele : SignalBus.Element, cooldown_time : float):
	match ele:
		SignalBus.Element.Water:
			water_spell_timer.wait_time = cooldown_time
			water_spell_timer.start()
		SignalBus.Element.Love:
			love_spell_timer.wait_time = cooldown_time
			love_spell_timer.start()
		SignalBus.Element.Light:
			light_spell_timer.wait_time = cooldown_time	
			light_spell_timer.start()
		SignalBus.Element.Song:
			song_spell_timer.wait_time = cooldown_time
			song_spell_timer.start()
		_:
			return false

func send_wand_progress():
	var water_prog : float = water_spell_timer.time_left / water_spell_timer.wait_time
	var love_prog : float = love_spell_timer.time_left / love_spell_timer.wait_time
	var light_prog : float = light_spell_timer.time_left / light_spell_timer.wait_time
	var song_prog : float = song_spell_timer.time_left / song_spell_timer.wait_time
	SignalBus.update_prog_bars.emit(water_prog, love_prog, light_prog, song_prog)

func generate_bullet_stats(element : SignalBus.Element) -> BulletStats:
	var percentage = spellbook[SignalBus.Element.find_key(element)]["percentage"]
	var stats = spellbook[SignalBus.Element.find_key(element)]["stats"].duplicate()
	stats.update_stats(percentage, element)
	return stats

func fire_bullet() -> void:
	var element_screenshot = current_element
	var start_pos : Vector2 = wand_point.global_position
	var dir : Vector2 = Vector2.RIGHT.rotated(wand_point.global_rotation - deg_to_rad(90))

	if !is_spell_ready(element_screenshot):
		return
	
	gen_bullet(element_screenshot, start_pos, dir)
		

func gen_bullet(element : SignalBus.Element, start_pos : Vector2, dir: Vector2, increase_cooldown=false):
	var bullet : Bullet = load(BULLET_SCENE_UID).instantiate() as Bullet
	var bullet_poly = spellbook[SignalBus.Element.find_key(element)]["poly"]
	var stats : BulletStats = generate_bullet_stats(element)
	get_tree().current_scene.add_child(bullet)
	bullet.setup(bullet_poly, start_pos, dir, stats)
	if increase_cooldown:
		trigger_cooldown(element, stats.cooldown * 1.5)
	else:
		trigger_cooldown(element, stats.cooldown)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		firing = true
	elif event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		firing = false

func update_bullet_poly(new_poly : PackedVector2Array, percentage_size : float, element : SignalBus.Element) -> void:
	var stupid_bullshit : BulletStats = BulletStats.new()
	stupid_bullshit.update_stats(percentage_size, element)
	spellbook[SignalBus.Element.find_key(element)] = {"poly" : new_poly, "percentage" : percentage_size, "stats": stupid_bullshit}
