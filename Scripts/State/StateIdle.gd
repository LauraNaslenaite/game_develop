extends State
class_name Idle

var x = load("res://Sprites/x-s-big.png") 
var o = load("res://Sprites/o-s-big.png") 

#changing sprite of a piece once it is in clickable state and is clicked on
func _clicked(piece, state_manage, sprite):
	
	if piece.symbol == "x":
		sprite.texture = x
	elif piece.symbol == "o":
		sprite.texture = o
#reseting default sprite of a piece
func reset(piece, sprite):
	if piece.symbol == "x":
		sprite.texture = x
	elif piece.symbol == "o":
		sprite.texture = o



