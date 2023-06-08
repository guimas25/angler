extends CharacterBody2D
class_name Box

const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var PUSHED = false
var direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/startmenu.tscn")
	
func push(vel: Vector2) -> void:
	velocity.x = vel.x
	move_and_slide()

