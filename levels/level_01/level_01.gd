extends Node2D

var enemy
var done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy = $Ancient

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(enemy):
		done = false
	if not is_instance_valid(enemy) and not done:
		done = true
		$StaticBody2D.queue_free()

func _on_area_2d_body_entered(body):
	SaveState.n_deaths = SaveState.n_deaths + 1 
	get_tree().reload_current_scene()


func _on_portal_body_entered(body):
	get_tree().change_scene_to_file("res://levels/level_05/level_05.tscn")
