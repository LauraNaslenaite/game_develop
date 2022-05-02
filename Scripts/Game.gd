extends Node

#creating systems
var movement_system = MovementSystem.new()
var generating_piece = GenerateNewPieceSystem.new()
var state_system = StateSystem.new()

var swipe = null

#creating a list
var a = ConcreteAggregate.new()
#creating an iterator for the list
var i = a._create_iterator()



func _ready():
	$Control.visible=false
	$Control2.visible=false
	#deleting any node present in the root node
	for i in get_tree().get_nodes_in_group("locations"):
		i.queue_free()
	state_system.reset()
	#reseting grid with default values
	reset_grid()

	generating_piece._add_playing_pieces($Grid, true)
	generating_piece._ready()

#process user input
func _unhandled_input(event):

	#The code below was written and adapted to my game while using some resources: 
	#https://www.youtube.com/watch?v=BWBD3i00AfM&t=504s
	#https://www.youtube.com/watch?v=m_hIIznWQZI&t=370s
	var direction = Vector2(0,0) 
	var progress = 1
	#keyboard input
	if event.is_action_pressed("ui_up"):
		direction = Vector2(0,1)
	elif event.is_action_pressed("ui_down"):
		direction = Vector2(0,-1)
	elif event.is_action_pressed("ui_left"):
		direction = Vector2(-1,0)
	elif event.is_action_pressed("ui_right"):
		direction = Vector2(1,0)
	#end 
	
	#swipe and click input
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			swipe = event.get_position()
		else:
			var x_difference = abs(event.get_position().x - swipe.x)
			var y_difference = abs(event.get_position().y - swipe.y)
			#the swipe must be of a certain length
			if  x_difference > y_difference and x_difference > 10:
				if  swipe.x < event.get_position().x:
					direction = Vector2(1,0)
				elif swipe.x > event.get_position().x:
					direction = Vector2(-1,0)
			elif x_difference < y_difference and y_difference > 10 :
				if swipe.y < event.get_position().y:
					direction = Vector2(0,-1)
				elif swipe.y > event.get_position().y:
					direction = Vector2(0, 1)
			else:
				#timer used to let the last piece of a match turn yellow
				var t = Timer.new()
				t.set_wait_time(1)
				t.set_one_shot(true)
				self.add_child(t)
				state_system.clicked_on_piece(t, event.get_position(), $Grid)
				progress=0
			swipe=null



	if direction != Vector2(0,0) and progress == 1:
		#check if there are any clicked pieces left that needs to be reseted
		state_system.uncheck_piece()
		
		#creating an iterator based on nodes that belong to group "location"
		var iterator = _get_list(get_tree().get_nodes_in_group("locations"))
		
		movement_system._get_grid_of_pieces(iterator, direction)

		state_system._get_pieces(iterator)
		
		#The following code was taken from :https://godotengine.org/qa/7042/wait-like-function
		var t = Timer.new()
		t.set_wait_time(0.2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		#end 
		
		#checking if a new piece was found
		var generated_a_piece = generating_piece.add_new_piece($Grid, 0)
		if generated_a_piece == false and is_grid_filled() == false:
			generated_a_piece= generating_piece.add_new_piece($Grid, 1)
		#if grid is filled and no possible matches are present - show Game Over popup
		if is_grid_filled() and any_valid_matches() ==false:
			$Control.visible = true
			$Pause.disabled = true


		state_system._get_pieces(_get_list(get_tree().get_nodes_in_group("locations")))
	direction = Vector2(0,0)
	progress = 1


# input param : get_tree().get_nodes_in_group("locations")
# creating a list using iterator pattern
func _get_list(array):
	var index = 0
	for piece in array: #actual piece node
		if piece.symbol == "empty" :
				continue
		#index - is the index and content in [piece obj, location obj] is the value at that index 
		a._add(index,[piece,_find_location_child(piece)])
		index += 1
	#since a list is of size 18, the remaining values need to be filled
	for rest in range(index, 18):
		a._add(rest, null)
	return a

#returns true if there are  any matches on the board
func any_valid_matches():
	#column
	var counter = 0
	for i in range(Globals.column_num):
		counter = 0
		for j in range(1,Globals.row_num,1):
			if Globals.grid[i][j] == Globals.grid[i][j-1] and Globals.grid[i][j-1] !="E":
				counter = counter +1 
			else:
				break
		if counter == 5 :
			return true
	
	#row
	for counter_r in range(Globals.row_num): # repeat 6 times  
		if Globals.grid[0][counter_r]  == Globals.grid[1][counter_r] and Globals.grid[1][counter_r] == Globals.grid[2][counter_r] and (Globals.grid[0][counter_r] == "x" or Globals.grid[0][counter_r] == "o"):
			return true

	
	#diagonal (from left corner to the right (upwards), from right corner to the left (downwards)
	var column_d_1 = 0
	for counter_d_1 in range(Globals.row_num-2): # repeat 4 times  
		if Globals.grid[column_d_1][counter_d_1]  == Globals.grid[column_d_1+1][counter_d_1+1] and Globals.grid[column_d_1][counter_d_1] == Globals.grid[column_d_1+2][counter_d_1+2] and (Globals.grid[column_d_1][counter_d_1] == "x" or Globals.grid[column_d_1][counter_d_1] == "o"):
			return true
	#diagonal (from left corner to the right (downwards), from right corner to the left (upwards)
	var column_d_2=0
	for counter_d_2 in range(2,Globals.row_num): # repeat 4 times  
		if Globals.grid[column_d_2][counter_d_2]  == Globals.grid[column_d_2+1][counter_d_2-1] and Globals.grid[column_d_2][counter_d_2] == Globals.grid[column_d_2+2][counter_d_2-2] and (Globals.grid[column_d_2][counter_d_2] == "x" or Globals.grid[column_d_2][counter_d_2] == "o"):
			return true

	return false



func _find_location_child(parent: Node) :
	for child in parent.get_children():
		if child is Location:
			return child
	return null
	
#Convert pixel to grid
func _pxl_to_grid(x, y):
	var column = (x - Globals.x_start)/ Globals.offset 
	var row = abs((y -Globals.y_start)/ -Globals.offset)
	return Vector2(column,row)



func _on_Restart_pressed():
	$Pause.disabled = false
	self.set_process_unhandled_input(true)
	$Control.visible = false
	_ready() 
	
#resetting the grid with default values
func reset_grid():
	for c in range(Globals.column_num):
		for r in range(Globals.row_num):
			Globals.grid[c][r] = "E"

#check if gridded is filled
func is_grid_filled():
	var filled=true
	for i in range(Globals.column_num):
		for j in range(Globals.row_num):
			if Globals.grid[i][j] != "E":
				filled = true
			else:
				return false
	return filled


func _on_Game_tree_exited():
	pass

func _on_Game_tree_exiting():
	state_system.reset()
	for n in self.get_children():
		n.queue_free()
	generating_piece.delete($Grid)
	generating_piece.queue_free()
	


func _on_Menu_pressed():
	$Pause.disabled = false
	self.set_process_unhandled_input(true)
	get_tree().change_scene("res://Scenes/Menu.tscn")


func _on_Replay_pressed():
	$Pause.disabled = false
	$Control.visible = false
	self.set_process_unhandled_input(true)
	for i in get_tree().get_nodes_in_group("locations"):
		i.queue_free()
	state_system.reset()
	_ready() 


func _on_Pause_pressed():
	$Control2.visible = true
	self.set_process_unhandled_input(false)



func _on_Return_pressed():
	self.set_process_unhandled_input(true)
	$Control2.visible = false
