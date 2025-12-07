extends AnimatedSprite2D
class_name ShrineWell

const MAX_HP : int = 4
const MAX_HITS : int = 1

signal all_done

@onready var hits = 0

func ready():
	self.play("default")
	
func increment_well():
	hits += 1
	match hits:
			1:
				self.play("Lvl1")
			2:
				self.play("Lvl2")
			3:
				self.play("Lvl3")
			4:
				self.play("Lvl4")
				all_done.emit()
			_: pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var bullet : Bullet = area
		if bullet.is_element(SignalBus.Element.Water):
			self.increment_well()
			area.dissapear()
