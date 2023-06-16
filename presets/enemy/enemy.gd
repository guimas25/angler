extends CharacterBody2D


const SPEED = 3000.0
const JUMP_VELOCITY = -400.0

var HP = 3

var is_moving_left = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	$Label.text = str(HP)
	if(HP <= 0):
		queue_free()
	detect_turn_around()

func _physics_process(delta):
	if is_moving_left:
		velocity.x = -SPEED * delta
	else:
		velocity.x = SPEED * delta
	velocity.y += gravity * delta
	move_and_slide()

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = not is_moving_left
		scale.x = -scale.x
		print("Turn around!")
		

func get_hurt():
	HP = HP-1
	print("OUCH!")
