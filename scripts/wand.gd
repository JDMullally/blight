extends Node2D

const BULLET_SCENE_UID : String = "uid://dkg2e45s87qw0"

@onready var spellbook : Dictionary = {}
@onready var wand_sprite : Sprite2D = $WandSprite
@onready var wand_point: Node2D = $WandSprite/WandPoint
var bullet_poly : PackedVector2Array

func _ready() -> void:
	bullet_poly = PackedVector2Array()
	bullet_poly.append(Vector2.ZERO)
	bullet_poly.append(Vector2(100, 0))
	bullet_poly.append(Vector2(100, 100))
	bullet_poly.append(Vector2(0, 100))
	bullet_poly.append(Vector2.ZERO)
	
	SignalBus.update_poly.connect(update_bullet_poly)

func _process(_delta : float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var to_mouse : Vector2 = mouse_pos - global_position
	rotation = to_mouse.angle()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var bullet : Area2D = load(BULLET_SCENE_UID).instantiate() as Area2D

		var start_pos : Vector2 = wand_point.global_position
		var mouse_pos : Vector2 = get_global_mouse_position()
		var dir : Vector2 = (mouse_pos - start_pos).normalized()
		
		var stupid_bullshit : BulletStats = BulletStats.new()
		
		get_tree().current_scene.add_child(bullet)
		bullet.setup(bullet_poly, start_pos, dir, stupid_bullshit)

func update_bullet_poly(new_poly : PackedVector2Array, percentage_size : float, element : SignalBus.Element) -> void:
	bullet_poly = new_poly
	spellbook[SignalBus.Element.find_key(element)] = new_poly
	print(SignalBus.Element.find_key(element))
