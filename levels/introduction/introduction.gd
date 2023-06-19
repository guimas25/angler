extends Node2D


var dark_1 = false
var dark_2 = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/Camera2D.limit_bottom = 384
	$Player/Camera2D.zoom = Vector2(3.5, 3.5)
	$Player/Camera2D.enabled = false
	$Camera2D.enabled = true
	$StaticBody2D/AnimationPlayer.play("float")
	$Sprite2D/AnimationPlayer.play("move_right")
	$Sprite2D2/AnimationPlayer.play("move_right")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimatedSprite2D.position.y = $StaticBody2D.position.y
	if $fishes.get_child_count() == 5:
		
