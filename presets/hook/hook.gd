extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	move_and_slide()

func hook_up():
	velocity.y = -500
	
func hooked():
	velocity.y = 0
	velocity.x = 0
	
func get_on_water():
	pass

func get_off_water():
	pass


# On area2d entered for water, area_entered, for fish, body_entered
# When area_entered happen, call get_parent().start_fishing()
