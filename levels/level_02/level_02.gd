extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Box2D.set_collision_layer_value(8, false)
	$Box2D.set_collision_mask_value(8, false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
