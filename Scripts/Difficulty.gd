extends Node2D


func _ready():
	pass # Replace with function body.


#setting global variable to false to indicate that an easy level was chosen
func _on_Easy_pressed():
	Globals.level_difficulty = false
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_Difficult_pressed():
	Globals.level_difficulty = true
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_GoBack_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")
