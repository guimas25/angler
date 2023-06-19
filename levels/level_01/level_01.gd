extends Node2D

var enemy_down = false
var enemy
var done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy = $Ancient


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(enemy) and not done:
		done = true
		checker()

func _on_area_2d_body_entered(body):
	get_tree().reload_current_scene()
	
func checker():
	$StaticBody2D.queue_free()
