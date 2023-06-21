extends Node2D

var hello = false
var started = false
var fade_out_done = false
var text_done = false
var click = false
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
	$StaticBody2D/Laura.play("default")
	$StaticBody2D/Miguel.play("default")
	$StaticBody2D/Sofia.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("melee_action") and not fade_out_done and hello:
		$CanvasLayer/ColorRect/AnimationPlayer.play("fade_out")
		fade_out_done = true
		SaveState.start_the_timer()
	
	if not $CanvasLayer/ColorRect.modulate == Color(255,255,255,0) and not text_done:
		$CanvasLayer/TextureRect/AnimationPlayer.play("fade_in")
		text_done = true
	$AnimatedSprite2D.position.y = $StaticBody2D.position.y
	if not click and Input.is_action_just_pressed("hook_action"):
		$CanvasLayer/TextureRect/AnimationPlayer.play("fade_out")
		click = true
		
	if $fishes.get_child_count() == 5 and not dark_1:
		dark_1 = true
		$ColorRect/AnimationPlayer.play("grey_1")
		$StaticBody2D/AnimationPlayer.play("float_2")

	if $fishes.get_child_count() == 3 and not dark_2:
		dark_2 = true
		$ColorRect/AnimationPlayer.play("grey_2")
		$StaticBody2D/AnimationPlayer.play("float_3")
		$CanvasLayer/Sprite2D/AnimationPlayer.play("drop")
		$CanvasLayer/Sprite2D/AnimationPlayer2.play("fade_in")
		$Timer.start()
		
func _input(event):
	if event is InputEventKey and event.pressed and not started:
		$CanvasLayer/ColorRect/AnimationPlayer.play("fade_in")
		started = true
		hello = true


func _on_timer_timeout():
	$CanvasLayer/ColorRect2/AnimationPlayer.play("fade_in")
	$CanvasLayer/ColorRect2.visible = true


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://levels/level_02/level_02.tscn")
