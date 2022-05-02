extends Node2D

var column_num=Globals.column_num
var row_num = Globals.row_num
var x_start = Globals.x_start
var y_start = Globals.y_start
var offset = Globals.offset


#creating a default 2D array
var Pieces =  preload("res://Scenes/emptyPiece.tscn")
			
#called when the node enters the scene tree for the first time.
func _ready():
	_initialise_grid()
	_display_default_pieces()

#the code below was taken from https://www.youtube.com/watch?v=XBUszx6qBWo
#and adapted to my own program
func _grid_to_pxl(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row;
	return Vector2(new_x,new_y)
#end


func _initialise_grid():
	Globals.grid.clear()
	for i in range(column_num):
		Globals.grid.append([])
		for j in range(row_num):
			Globals.grid[i].append("E")  # E - empty; X; O.
	
	
#display white pieces
func _display_default_pieces():
	for i in range(column_num):
		for j in range(row_num):
			#creating an instance of an object
			var empty_piece = Pieces.instance()
			#adding a node to the grid node
			add_child(empty_piece)
			var position_empty_p = _grid_to_pxl(i,j)
			#positioning on a board
			empty_piece.position = Vector2(position_empty_p[0], position_empty_p[1])
			
