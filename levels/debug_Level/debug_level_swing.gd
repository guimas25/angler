extends Node2D

var can_hook = true
var hooked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!hooked):
		$hook.position.x = $Player.position.x + 35
		$hook.position.y = $Player.position.y
	if(can_hook && Input.is_action_just_pressed("hook_action")):
		hooked = true
		$Timer.start()
		$hook.hook_up()

func _physics_process(delta):
	pass

func _on_stop_body_entered(body):
	if(body == $hook):
		$hook.hooked()
		$Player.velocity.y = -1000
		hooked = false


func _on_timer_timeout():
	hooked = false


func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/debug_level_fight.tscn")
