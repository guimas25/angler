extends Node2D

var casted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("hook_action"):
		pass


func _on_area_2d_body_entered(body):
	$hook.hooked()
