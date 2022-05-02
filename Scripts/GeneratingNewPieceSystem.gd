class_name GenerateNewPieceSystem
extends Node
var column_num=Globals.column_num
var row_num = Globals.row_num
var x_start = Globals.x_start
var y_start = Globals.y_start
var offset = Globals.offset
var Pieces_individual = [ preload("res://Scenes/x_Node2D.tscn"),
						  preload("res://Scenes/0_Node2D.tscn")]

var all_possible_positions= []
func _ready():
	all_coord()

	
#initialising an array containing all possible positions on a grid
func all_coord():
	for i in range(column_num):
		for j in range(row_num):
			all_possible_positions.append([i,j])

#deleting created nodes
func delete(node):
	for n in node. get_children():
		n._delete()
		n.queue_free()

#The code below was taken from https://www.youtube.com/watch?v=XBUszx6qBWo
#and adapted to my own program
func _grid_to_pxl(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row;
	return Vector2(new_x,new_y)
#end


#initialisation -adding 3 random pieces - T/F
func _add_playing_pieces(node, initialise):
	
	var times
	if initialise:
		times = 3

	else:
		times = 1
			
	while times > 0:
		var coord = _generate_rand_coord()
		
		#get coordinates
		while Globals.grid[coord[0]][coord[1]] != "E":
			coord = _generate_rand_coord()
		#generate a random symbol (x or o)
		var random = RandomNumberGenerator.new()
		random.randomize()
		var rand_piece_symbol = random.randi_range(0,1)
		
		place_new_piece(node, rand_piece_symbol, coord)
		times -= 1

#placing a new piece
#input param: node - where the node will be added,
#chosen_symbol - x or o
#coord - grid coordinates
func place_new_piece(node, chosen_symbol, coord):
	var one_piece = Pieces_individual[chosen_symbol].instance()
	node.add_child(one_piece)
	var positions = _grid_to_pxl(coord[0], coord[1])
	#updating a global variable - grid
	Globals.grid[coord[0]][coord[1]] = one_piece.symbol
	#placing a piece on a board
	one_piece.position = Vector2(positions[0], positions[1])
	one_piece._set_coordinates(coord[0], coord[1]) 

# random coordinates are generated where 
# x is 0-2
# y is 0-5
func _generate_rand_coord():
	var random = RandomNumberGenerator.new()
	random.randomize()
	var new_x = random.randi_range(0,2)
	var new_y = int(rand_range(0,5))
	var coord = [new_x,new_y]
	return coord 
	
	
#AI part 
#finding a coordinates based on difficulty 
func add_new_piece(node, any_piece):
	var symbol
	var alt_symbol
	#shuffling a list of all possible coordinates
	randomize()
	all_possible_positions.shuffle()
	
	#looping through that list 
	for i in range(all_possible_positions.size()):
#		
		var coord = all_possible_positions[i]
		#making sure that coordinates are not in use
		if Globals.grid[coord[0]][coord[1]] != "E":
			continue
		#producing a radondom symbol
		var random = RandomNumberGenerator.new()
		random.randomize()
		var rand_piece_symbol = random.randi_range(0,1)


		if rand_piece_symbol == 0:
			symbol = "x"
			alt_symbol="o"
		else:
			symbol = "o"
			alt_symbol="x"
		
		var grid = Globals.grid.duplicate(true)
		
		var found = find_position(grid, coord[0],coord[1],symbol)
		
		#if level is difficult
		if Globals.level_difficulty:
			#if coordinates are do not make up a match or no other options are available
			if found==true or any_piece==1:
				place_new_piece(node, rand_piece_symbol, Vector2(coord[0],coord[1]))
				return true
				break
			#elif - analysis the validity of the same coordinates just with another symbol, conditions are the same
			elif find_position(grid, coord[0],coord[1],alt_symbol) == true  or any_piece==1 :
				if rand_piece_symbol ==1:
					rand_piece_symbol =0
				else:
					rand_piece_symbol=1
				place_new_piece(node, rand_piece_symbol, Vector2(coord[0],coord[1]))
				return true
				break
			else:
				#coordinates not accepted, try another 
				continue
				
		#if level is easy
		else:
			#if coordinates that produce a match are found or coordinates that do not produce a match and i is even or let any empty coordinate pass the conditions
			if  found == false or (found==true and (i%2==0)) or any_piece == 1:
				place_new_piece(node, rand_piece_symbol, Vector2(coord[0],coord[1]))
				return true
				break
			#same conditions just with another symbol
			elif (find_position(grid, coord[0],coord[1],symbol) == false or (find_position(grid, coord[0],coord[1],symbol) == true) and (i%2==0)) or any_piece==1 :
				if rand_piece_symbol ==1:
					rand_piece_symbol =0
				else:
					rand_piece_symbol=1
				place_new_piece(node, rand_piece_symbol, Vector2(coord[0],coord[1]))
				return true
				break
			else:
				continue
		
	return false
	
#finding a position for a new piece
#returns true is if there is a match with a new piece 
#		 false - no match for the new piece
func find_position(board, x, y, symbol):
	
	var temp_board = board.duplicate(true)	
	#placing a piece on the board based on the coordinates x, y
	temp_board[x][y] = symbol 

	var direction = 1
	var result = false
	var counter = 0
	
	#checking if for every different movement (up, down, left, right) - inputed coordinates produce a match
	for i in range(1,5):
		var t_board = temp_board.duplicate(true)
		var board_altered1 = [] 
		#the placed piece is moved and placed on a new location based on moving direction
		board_altered1 = simulate_move(t_board,i, x,y)

		#checking if there is a match after the simulated move
		result=match_check_for_simulated_move(board_altered1[0],board_altered1[1][0],board_altered1[1][1])

		if result: # there is no match after placing a new piece and moving to different directions
			return false
	return true

			
# 1st STEP: finding where the piece would be placed on a board after a move
func simulate_move(board, direction, x, y):
	var new_coord = Vector2(x,y)
	
	if direction == 1: #"up":
		#looping through the board
		for j in range(column_num):  
			#starting from the top ,second last row
			for i in range(row_num-2, -1, -1):
				if board[j][i] != "E":
					#finding an empty cell that would be at the most top position
					for k in range(row_num-1, i, -1):
						if board[j][k] == "E":
							board[j][k] = board[j][i]
							if j == x and i ==y:
#								#finding new coordinates after a move of the piece that we are trying to place
								new_coord=Vector2(j, k)
							board[j][i] = "E"
							break
	elif direction == 2: # "down" 
		for j in range(column_num):  
			#starting from the bottom ,second last row
			for i in range(1,row_num, 1):
				if board[j][i] != "E":
					#finding an empty cell that would be at the lowest position
					for k in range(0, i, 1):
						if board[j][k] == "E":
							board[j][k] = board[j][i]
							if j == x and i ==y:
								new_coord=Vector2(j, k)
							board[j][i] = "E"
							break
	elif direction == 3: # "left" 
		for j in range(1,column_num):  
			for i in range(0,row_num):
				if board[j][i] != "E":
					#finding an empty cell that would be at the most left position
					for k in range(0, j):
						if board[k][i] == "E":
							board[k][i] = board[j][i]
							if j == x and i ==y:
								new_coord=Vector2(k, i)
							else:
								new_coord=Vector2(x,y)
							board[j][i] = "E"
							break
	elif direction ==  4: #"right":
		for j in range(column_num-2, -1, -1):  
			for i in range(0,row_num):
				if board[j][i] != "E":
					#finding an empty cell that would be at the most right position
					for k in range(column_num-1, j, -1):
						if board[k][i] == "E":
							board[k][i] = board[j][i]
							if j == x and i ==y:
								new_coord=Vector2(k, i)
							else:
								new_coord=Vector2(x,y)
							board[j][i] = "E"
							break 
	return [board, new_coord]
	
#2nd STEP: checking if there is a match after STEP 1 with a placed piece
#param : updated board, new coordinates of the piece
#return : true - there is a match, false - no match 
func match_check_for_simulated_move(board, x, y):
	#column
	var x_sign=0
	var o_sign=0 
	for j in range(row_num):
		if board[x][j] == "x":
			x_sign= x_sign+1
		elif board[x][j] == "o":
			o_sign = o_sign+1
	if x_sign == 6 or o_sign==6 :
		return true
	
	#row
	if board[0][y]  == board[1][y] and board[1][y] == board[2][y] and (board[0][y] == "x" or board[0][y] == "o"):
		return true

	
	#diagonal (from left corner to the right (upwards), from right corner to the left (downwards)
	var column_d_1 = 0
	for counter_d_1 in range(row_num-2): # repeat 4 times  
		if board[column_d_1][counter_d_1]  == board[column_d_1+1][counter_d_1+1] and board[column_d_1][counter_d_1] == board[column_d_1+2][counter_d_1+2] and (board[column_d_1][counter_d_1] == "x" or board[column_d_1][counter_d_1] == "o") and (board[column_d_1][counter_d_1]==board[x][y] or board[column_d_1+1][counter_d_1+1] == board[x][y] or board[column_d_1+2][counter_d_1+2]==board[x][y]):
			return true

	#diagonal (from left corner to the right (downwards), from right corner to the left (upwards)
	var column_d_2=0
	for counter_d_2 in range(2,row_num): # repeat 4 times  
		if board[column_d_2][counter_d_2]  == board[column_d_2+1][counter_d_2-1] and board[column_d_2][counter_d_2] == board[column_d_2+2][counter_d_2-2] and (board[column_d_2][counter_d_2] == "x" or board[column_d_2][counter_d_2] == "o") and (board[column_d_2][counter_d_2]==board[x][y] or board[column_d_2+1][counter_d_2-1] == board[x][y] or board[column_d_2+2][counter_d_2-2]==board[x][y]):
			return true
			
	return false
