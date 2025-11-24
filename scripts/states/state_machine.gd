extends Node
class_name StateMachine

@export var monster : Monster
@export var initial_state: MonsterState
@onready var label: Label = $"../Label"

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
		label.text = str(current_state.name)

func _physics_process(_delta: float) -> void:
	current_state.on_tick()

func set_kill_state():
	_on_transition_request(current_state, MonsterState.State.Dead, monster)


func _on_transition_request(from: MonsterState, to: MonsterState.State, sent_monster : Monster):
	if sent_monster == monster:
		if from != current_state:
			return
		
		var new_state: MonsterState = states[to]
		if not new_state:
			print(to, " is not in ", states)
			return
		
		if current_state:
			current_state.exit()
		
		new_state.enter()
		current_state = new_state
		label.text = str(current_state.name)
