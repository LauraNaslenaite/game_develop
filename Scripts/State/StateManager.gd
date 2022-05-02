#Implementation was based on https://www.dofactory.com/net/state-design-pattern
extends Node
class_name State_manager

#reference to a state
var state : State

func _change_state(new_state):
	state = new_state

func _get_state():
	return state

#based on a state , call _clicked method for state obj
func _clicked1(piece, sprite):
	state._clicked(piece,self, sprite)
	
func reset(piece, sprite):
	state.reset(piece, sprite)

	
