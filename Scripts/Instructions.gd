extends Node2D


func _ready():
	pass # Replace with function body.

func _on_AnimationPlayer_animation_started(anim_name):
	pass


func _on_GoBack_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")
