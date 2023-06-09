extends RigidBody2D
class_name Box

const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var PUSHED = false
var direction = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	pass

func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/startmenu.tscn")

func _integrate_forces(state):
	angular_velocity = 0
	rotation_degrees = 0

