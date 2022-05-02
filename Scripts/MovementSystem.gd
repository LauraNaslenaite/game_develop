class_name MovementSystem
extends Reference



var column_num=Globals.column_num
var row_num = Globals.row_num
var x_start = Globals.x_start
var y_start = Globals.y_start
var offset = Globals.offset

var array_pieces = []


#getting pieces and storing them in a array_piece variable
func _get_grid_of_pieces(a, direction):

	var i = a._create_iterator() ## iterator
	var item = i._get_current()
	
	#initialising a list variable
	for l in range(column_num):
		array_pieces.append([])
		for j in range(row_num):
			array_pieces[l].append(null)
		
	#while using iterator, looping through input list 'a' and storing 
	# its items in an array_piece 
	while item != null:
		var pos = 0
		
		var r = item[1].x_coord
		var c = item[1].y_coord
		array_pieces[r][c] = item
		item = i._get_next()

	
	_get_moving_coordinates(direction)
	
#moving each piece based on direction
func _get_moving_coordinates(direction):
	if direction == Vector2(0, 1): #"up":
		#looping through the board
		for j in range(column_num):  
			#starting from the top ,second last row
			for i in range(row_num-2, -1, -1):
				if array_pieces[j][i] != null:
					#finding an empty cell that would be at the most top position
					for k in range(row_num-1, i, -1):
						if array_pieces[j][k] == null:
							array_pieces[j][k] = array_pieces[j][i]
							_move(array_pieces[j][k],j, k,direction)
							array_pieces[j][i] = null
							break
					
	elif direction == Vector2(0,-1): #"down" 
		for j in range(column_num):  
			for i in range(1,row_num, 1):
				if array_pieces[j][i] != null:
					for k in range(0, i, 1):
						if array_pieces[j][k] == null:
							array_pieces[j][k] = array_pieces[j][i]
							_move(array_pieces[j][k],j, k,direction)
							array_pieces[j][i] = null
							break
	elif direction == Vector2(-1, 0): #"left" 
		for j in range(1,column_num):  
			for i in range(0,row_num):
				if array_pieces[j][i] != null:
					for k in range(0, j):
						if array_pieces[k][i] == null:
							array_pieces[k][i] = array_pieces[j][i]
							_move(array_pieces[k][i],k, i,direction)
							array_pieces[j][i] = null
							break
	elif direction == Vector2(1,0): #"right":
		for j in range(column_num-2, -1, -1):  
			for i in range(0,row_num):
				if array_pieces[j][i] != null:
					for k in range(column_num-1, j, -1):
						if array_pieces[k][i] == null:
							array_pieces[k][i] = array_pieces[j][i]
							_move(array_pieces[k][i],k, i,direction)
							array_pieces[j][i] = null
							break

	array_pieces.clear()

#moving a piece, updating the global grid variable
func _move(piece_obj, new_x, new_y, direction):
	Globals.grid[piece_obj[1].x_coord][piece_obj[1].y_coord] = "E"

	#up or down
	if direction == Vector2(0,1) or direction == Vector2(0,-1) :
		piece_obj[0].position = _grid_to_pxl(piece_obj[1].x_coord, new_y)
		piece_obj[1].y_coord = new_y
		Globals.grid[piece_obj[1].x_coord][new_y] = piece_obj[0].symbol
	#left or right
	elif direction == Vector2(-1,0) or direction == Vector2(1,0):
		piece_obj[0].position = _grid_to_pxl(new_x, piece_obj[1].y_coord )
		piece_obj[1].x_coord = new_x
		Globals.grid[new_x][piece_obj[1].y_coord] = piece_obj[0].symbol
	
	
	
#The code below was taken from https://www.youtube.com/watch?v=XBUszx6qBWo
#and adapted to my own program
func _grid_to_pxl(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row;
	return Vector2(new_x,new_y)

