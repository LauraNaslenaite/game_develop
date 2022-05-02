class_name Location
extends Node

#coordinates of a piece - Piece_as_Node2D
export var x_coord = 0
export var y_coord = 0

func delete():
	self.queue_free()
