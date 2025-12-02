extends Node2D
class_name WaterShrine

const MAX_THRESHOLD : int = 4
const WIDTH : float = 640.0
const HEIGHT : float = 320.0
const MAX_HITS : int = 2

const MAX_HP = 4

@onready var shrine_sprite: Sprite2D = $ShrineSprite
@onready var top_left_well: Well = %TopLeftWell
@onready var top_right_well: Well = %TopRightWell
@onready var bottom_left_well: Well = %BottomLeftWell
@onready var bottom_right_well: Well = %BottomRightWell
@onready var increment : float = 640.0
@onready var threshold : int = 0
@onready var hitpoints = 0


func _ready() -> void:
	top_left_well.all_done.connect(heal_shrine)
	top_right_well.all_done.connect(heal_shrine)
	bottom_left_well.all_done.connect(heal_shrine)
	bottom_right_well.all_done.connect(heal_shrine)

func heal_shrine():
	hitpoints += 1
	
	if hitpoints < MAX_HP:
		threshold = clampi(threshold + 1, 0, MAX_THRESHOLD)
		var current_atlas_texture : AtlasTexture = shrine_sprite.texture
		current_atlas_texture.region = Rect2(increment * threshold, 0.0, WIDTH, HEIGHT)
	
	if MAX_HP == hitpoints:
		var current_atlas_texture : AtlasTexture = shrine_sprite.texture
		current_atlas_texture.region = Rect2(increment * (threshold + 1), 0.0, WIDTH, HEIGHT)
		SignalBus.unlock_spell.emit(SignalBus.Element.Love)
		SignalBus.complete_shrine.emit()
