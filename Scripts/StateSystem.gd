class_name StateSystem
extends Reference

var column_num=Globals.column_num
var row_num = Globals.row_num
var x_start = Globals.x_start
var y_start = Globals.y_start
var offset = Globals.offset

#stores Piece obj as values and coordinates as keys
var state_pieces_dic = {}
var clicked_pieces= {}

func _get_pieces(pieces):
	state_pieces_dic.clear()
	
	var i = pieces._create_iterator() ## iterator
	var item = i._get_current()
	
	#iterating through a list and storing its items based on coordinates(as key values) in a dictionary
	while item != null:
		var pos = 0
		var x = item[1].x_coord
		var y = item[1].y_coord
		var loc = Vector2(x, y)
		state_pieces_dic[loc] = item
		
		item = i._get_next()
		
	reset_states()
	check_match()
	
#checking for a match
func check_match():
	var match_coord = get_match_coord()
	if match_coord.size() != 0 : # there is a match
		change_state(match_coord)
	else:
		reset_states()
#
#	for k in state_pieces_dic.keys():
#		print(k, " ---> ", state_pieces_dic[k][0].clickable)

#finding all matches and returning a list of them
func get_match_coord():
	#column
	var list_of_matches= []
	var counter = 0
	for i in range(column_num):
		counter = 0
		for j in range(1,row_num,1):

			if Globals.grid[i][j] == Globals.grid[i][j-1] and Globals.grid[i][j-1] !="E":
				counter = counter +1 
			else:
				break
		

		if counter == 5 :#
			list_of_matches.append([Vector2(i, 0), Vector2(i, 1) , Vector2(i, 2), Vector2(i, 3), Vector2(i, 4), Vector2(i, 5)] )

	#row
	for counter_r in range(row_num): # repeat 6 times  

		if  Globals.grid[0][counter_r]  ==  Globals.grid[1][counter_r] and  Globals.grid[1][counter_r] ==  Globals.grid[2][counter_r] and ( Globals.grid[0][counter_r] == "x" or  Globals.grid[0][counter_r] == "o"):
			list_of_matches.append([Vector2(0, counter_r), Vector2(1, counter_r),  Vector2(2, counter_r)])

	#diagonal (from left corner to the right (upwards), from right corner to the left (downwards)
	var column_d_1 = 0
	for counter_d_1 in range(row_num-2): # repeat 4 times  
		if  Globals.grid[column_d_1+2][counter_d_1+2]  ==  Globals.grid[column_d_1+1][counter_d_1+1] and Globals.grid[column_d_1][counter_d_1]  ==  Globals.grid[column_d_1+1][counter_d_1+1] and  Globals.grid[column_d_1][counter_d_1] ==  Globals.grid[column_d_1+2][counter_d_1+2] and ( Globals.grid[column_d_1][counter_d_1] == "x" or  Globals.grid[column_d_1][counter_d_1] == "o"):
			list_of_matches.append([Vector2(column_d_1, counter_d_1), Vector2(column_d_1+1, counter_d_1+1),  Vector2(column_d_1+2, counter_d_1+2)])

	#diagonal (from left corner to the right (downwards), from right corner to the left (upwards)
	var column_d_2=0
	for counter_d_2 in range(2,row_num): # repeat 4 times  
		if  Globals.grid[column_d_2][counter_d_2]  ==  Globals.grid[column_d_2+1][counter_d_2-1] and  Globals.grid[column_d_2][counter_d_2] ==  Globals.grid[column_d_2+2][counter_d_2-2] and ( Globals.grid[column_d_2][counter_d_2] == "x" or  Globals.grid[column_d_2][counter_d_2] == "o"):
			list_of_matches.append([Vector2(column_d_2, counter_d_2), Vector2(column_d_2+1, counter_d_2-1),  Vector2(column_d_2+2, counter_d_2-2)])
	return list_of_matches	
		
#processing a click 
#input : t- timer
# 		position - coordintates of a click in pixels
#		node - from which node the piece will be deleted
func clicked_on_piece(t, position, node):
	#converting pixels into grid coordinates
	var new_coord = _pxl_to_grid(position[0], position[1])
	var coord = Vector2(int(round(new_coord[0])), int(round(new_coord[1])))
	
	#loop through list with pieces
	for piece in state_pieces_dic.keys():
		#if a pice has matching coordinates with a click ,continue
		if piece == coord:
			#add a piece that was clicked on in to another list
			clicked_pieces[coord] = state_pieces_dic[coord][0]
			#change a state of that piece
			state_pieces_dic[coord][0]._state()
			#timer is added to make the last piece that is clicked on change colour
			t.start()
			yield(t, "timeout")
	eliminate_pieces_conditions(node)

#checking if selected pieces can be distroyed 
func eliminate_pieces_conditions(node):


	if clicked_pieces.size() > 1:
		#check for column match , x must be the same
		var key_x_compare = []
		for k in clicked_pieces.keys():
			key_x_compare.append(k)
		if key_x_compare[0][0] == key_x_compare[1][0]:
			#for a column match 
			if clicked_pieces.size() == 6:
				eliminate_pieces(node)
		else:
			#for all the other matches
			if clicked_pieces.size() == 3:
				eliminate_pieces(node)

#eliminating pieces
func eliminate_pieces(node):
	for key in clicked_pieces.keys():
		#removing from parent node
		node.remove_child(state_pieces_dic[key][0])

		#removing the piece from the group - 'location'
		clicked_pieces[key].remove_from_group("locations")
		#deleting the piece from  local variables
		state_pieces_dic.erase(key) 
		clicked_pieces[key]._delete()
		clicked_pieces[key].queue_free()
		#updating global variable grid
		Globals.grid[key[0]][key[1]] = "E"
	clicked_pieces.clear()
	#update states after eliminating some pieces in case there is more then 1 match
	# at once
	check_match() 

#changing state to clickable
#intput param : [ [match1], [match2] ] 
func change_state(array_of_coord):
	for m in array_of_coord:
		for coord in m:
			state_pieces_dic[coord][0].clickable="yes"

#changing state to idle
func reset_states():
	for coord in state_pieces_dic.keys():
		state_pieces_dic[coord][0].clickable = "no"


#convert pixels to grid 	
func _pxl_to_grid(x, y):
	var column = (x - x_start)/ offset 
	var row = abs((y -y_start)/ -offset)
	return Vector2(column,row)

#resetting local variables
func reset():
	state_pieces_dic.clear()
	clicked_pieces.clear()

#if there are only few pieces selected but they dont make up the full match and a player decides
#to move pieces instead, the clicked pieces are set to have an idle state 
func uncheck_piece():
	if clicked_pieces.size() != 0:
		for i in clicked_pieces.keys():
			clicked_pieces[i].clickable = "no"
			clicked_pieces[i].reset_sprite()
	
		clicked_pieces.clear()
