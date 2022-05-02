extends Node2D


func _ready():
	pass # Replace with function body.

#go to difficulty page
func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/Difficulty.tscn")


func _on_Menu_tree_exited():
	self.queue_free()


func _on_Instructions_pressed():
	get_tree().change_scene("res://Scenes/Instructions.tscn")


func _on_Exit_pressed():
	get_tree().quit()
