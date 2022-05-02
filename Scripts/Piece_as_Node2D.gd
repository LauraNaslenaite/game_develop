class_name Piece
extends Node2D


#script variable
export (String) var symbol
export (String) var clickable 
onready var icon = $Sprite
onready var location = $Location

var state = State_manager.new()

#updating coordinates of a newly creating piece
func _set_coordinates(x, y):
	location.x_coord = x
	location.y_coord = y
	
#chaging a state
func _state():
	if clickable == "yes":
		state._change_state(Clickable.new())
		state._clicked1(self,icon)
	else:
		state._change_state(Idle.new())
		state._clicked1(self,icon)

func _delete():
	location.delete()
	for n in state.get_children():
		n.queue_free()
	state.queue_free()
	icon.queue_free()
	state.queue_free()


func reset_sprite():
	if self.symbol == "x":
		$Sprite.texture = load("res://Sprites/x-s-big.png") 
	elif self.symbol == "o":
		$Sprite.texture = load("res://Sprites/o-s-big.png")
	


