extends Node2D


# Called when the node enters the scene tree for the first time.

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	get_tree().change_scene_to_file("res://levels/level_04/level_04.tscn")
