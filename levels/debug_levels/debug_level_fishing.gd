extends Node2D
 
func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/debug_level_pulling_fish.tscn")

func _ready():
	print($water_body)
