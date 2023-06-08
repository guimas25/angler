extends Node2D

var can_hook = true
var hooked = false
var _start_minigame = false
var scale_merda = 30
var got_fish = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!hooked):
		if $Player/Sprite2D.flip_h:
			$hook.position.x = $Player.position.x - 50
		else:
			$hook.position.x = $Player.position.x + 50
		$hook.position.y = $Player.position.y
	if(can_hook && Input.is_action_just_pressed("hook_action")):
		hooked = true
		$hook.velocity.x = 300
		$hook.velocity.y = 300
		if $Player/Sprite2D.flip_h:
			$hook.velocity.x = -300
		can_hook = false
		$Timer.start()
	if Input.is_action_just_pressed("hook_action") and _start_minigame:
		if $Player/ColorRect/Sprite2D.position.x >= 270 and $Player/ColorRect/Sprite2D.position.x <= 310:
			can_hook = true
			hooked = false
			got_fish = true
			_start_minigame = false
			$Player/ColorRect/Sprite2D.position.x = 20
			$Player/nice.visible = true
			$Timer2.start()
		else:
			$Player/nice2.visible = true
			$Timer2.start()
			can_hook = true
			hooked = false
			_start_minigame = false
			$Player/ColorRect/Sprite2D.position.x = 20
		# 270, 310
	if _start_minigame:
		$Player/ColorRect.visible = true
		$Player/ColorRect/Sprite2D.position.x = $Player/ColorRect/Sprite2D.position.x + 10 * delta * scale_merda 
		if $Player/ColorRect/Sprite2D.position.x >= 390:
			$Player/nice2.visible = true
			$Timer2.start()
			_start_minigame = false
			$Player/ColorRect/Sprite2D.position.x = 20
			can_hook = true
			hooked = false
	else:
		$Player/ColorRect.visible = false

func _on_area_2d_body_entered(body):
	if not can_hook:
		$hook.hooked()
		body.IMHOOKHELP()
		print("HEEOEOEOEO")
		$Timer.stop()
		_start_minigame = true
	

func _on_timer_timeout():
	can_hook = true
	hooked = false


func _on_area_2d_body_exited(body):
	if got_fish:
		body.queue_free()
		got_fish = false
	else:
		body._on_timer_timeout()
		body.go_timer()


func _on_timer_2_timeout():
	$Player/nice.visible = false
	$Player/nice2.visible = false


func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/debug_level_pulling_fish.tscn")
