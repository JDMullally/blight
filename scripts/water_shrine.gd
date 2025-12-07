extends Node2D
class_name WaterShrine

const MAX_THRESHOLD : int = 4
const WIDTH : float = 640.0
const HEIGHT : float = 320.0
const MAX_HITS : int = 2

const MAX_HP = 4

@onready var shrine_sprite: AnimatedSprite2D = $ShrineSprite
@onready var top_left_well: ShrineWell = %TopLeftWell
@onready var top_right_well: ShrineWell = %TopRightWell
@onready var bottom_left_well: ShrineWell = %BottomLeftWell
@onready var bottom_right_well: ShrineWell = %BottomRightWell
@onready var increment : float = 640.0
@onready var threshold : int = 0
@onready var hitpoints = 0


func _ready() -> void:
	top_left_well.all_done.connect(heal_shrine)
	top_right_well.all_done.connect(heal_shrine)
	bottom_left_well.all_done.connect(heal_shrine)
	bottom_right_well.all_done.connect(heal_shrine)
	shrine_sprite.animation_finished.connect(play_full)
	shrine_sprite.play("water_shrine_corrupted")

func heal_shrine():
	hitpoints = clampi(hitpoints+1,0,4)
	if hitpoints == 4:
		SignalBus.complete_shrine.emit()
		SignalBus.debuff_shrine.emit(SignalBus.Element.Water)
		SignalBus.unlock_spell.emit(SignalBus.Element.Song)
		shrine_sprite.play("water_shrine_healing")

func play_full():
	if shrine_sprite.animation=="water_shrine_healing":
		shrine_sprite.play("water_shrine_full")
