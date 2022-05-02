extends State
class_name Clickable


#to change the sprite of a piece once it is clicked on
var coloured_x = load("res://Sprites/x-s-coloured.png") 
var coloured_o = load("res://Sprites/o-s-coloured.png") 

#changing sprite of a piece once it is in clickable state and is clicked on
func _clicked(piece, state_manage, sprite):
	
	if piece.symbol == "x":
		sprite.texture = coloured_x
	elif piece.symbol == "o":
		sprite.texture = coloured_o


func reset(piece, sprite):
	pass
