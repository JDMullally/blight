class_name MonsterState
extends Node

enum State {Idle, Chase, Hit, Cooldown}

signal transition_requested(from: MonsterState, to: State)

@export var state: State
@export var monster : Monster

# var draggable_food_item : DraggableFoodItem

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func on_tick() -> void:
	pass

func _physics_process(delta: float) -> void:
	on_tick()
