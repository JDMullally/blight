extends Node
class_name StateMachine

@export var monster : Monster
@export var initial_state: MonsterState

var current_state : MonsterState
var states := {}

func _ready() -> void:
	for child in get_children():
		if child is MonsterState:
			states[child.state] = child
			child.transition_requested.connect(_on_transition_request)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _on_transition_request(from: MonsterState, to: MonsterState.State):
	if from != current_state:
		return
	
	var new_state: MonsterState = states[to]
	if not new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
