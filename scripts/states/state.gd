class_name MonsterState
extends Node

enum State {Spawn, Despawn, Idle, Chase, Hit, Cooldown, Dead, Dazzle, Stun}

signal transition_requested(from: MonsterState, to: State)

@export var state: State
@export var monster : Monster

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func on_tick() -> void:
	pass
