extends CharacterBody2D


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

	if PUSHED == true:
		
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, 30)
		else:
			velocity.x = move_toward(velocity.x, 0, 50)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_and_slide()


func _on_area_2d_left_body_entered(body):
	print("body entered")
	PUSHED = true
	direction = 1


func _on_area_2d_left_body_exited(body):
	print("body exited")
	PUSHED = false
	velocity.x = 0


func _on_area_2d_2_right_body_entered(body):
	print("body entered")
	PUSHED = true
	direction = -1


func _on_area_2d_2_right_body_exited(body):
	print("body exited")
	PUSHED = false
	velocity.x = 0


func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/startmenu.tscn")
