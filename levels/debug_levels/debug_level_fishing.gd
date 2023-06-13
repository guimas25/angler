extends Node2D
 
var body_hooked

var pull = false

func _physics_process(delta):
	if pull:
		body_hooked.position = $Hook.position
		if($Hook.velocity.y > 0):
			pull = false
			body_hooked.queue_free()

func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/debug_level_pulling_fish.tscn")

func _on_player_throw_signal(pos, vel):
	pass

func _on_player_got_fish():
	pass

func _on_hook_start_minigame(body):
	pass
