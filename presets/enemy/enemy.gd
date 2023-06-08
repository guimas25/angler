extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var random_direction = 0

var HP = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	$Label.text = str(HP)
	if(HP <= 0):
		queue_free()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	var random_jump = randi_range(1, 100)
	
	if(random_jump == 100 && is_on_floor()):
		velocity.y = JUMP_VELOCITY

	
	if(random_direction <= 5):
		velocity.x = 100
	else:
		velocity.x = -100

	move_and_slide()

func _on_timer_timeout():
	random_direction = randi_range(1, 10)


func _on_hit_box_damage_area_entered(area):
	pass # Replace with function body.

func get_hurt():
	HP = HP-1
	print("OUCH!")
