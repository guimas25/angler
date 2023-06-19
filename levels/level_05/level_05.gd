extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")
	$Player/Camera2D.limit_bottom = 460
	$Player/Camera2D.limit_top = -1859
	$Player/Camera2D.limit_left = 37
	$Player/Camera2D.limit_right = 1094


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
