extends CharacterBody2D
class_name Fish_simple

@export var SPEED = 300.0
const JUMP_VELOCITY = -400.0
const X_VELOCITY = 40
const Y_VELOCITY = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var x_vel = 0
var y_vel = 0
var x_dir = 1
var y_dir = 0

var bait_body
var get_bait = false

func _ready():
	$AnimatedSprite2D.play("default")
	randomize()
	velocity.x = randi_range(20,41)
	velocity.y = randi_range(20,41)

func _physics_process(delta):
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	var check_bait = weakref(bait_body)           # Try to get reference to the bait 
	if check_bait.get_ref():                      # If it was able to, object still on the loose!
		if get_bait and bait_body is Hook_Simple:
			velocity = Vector2(bait_body.position.x - position.x, bait_body.position.y - position.y)
			velocity = velocity.normalized() * randf_range(30,51)
	
	move_and_slide()

func hooked():
	$Timer.stop()
	velocity.x = 0
	velocity.y = 0
	get_bait = false
	$Timer_take_bait.stop()           # Stop random timer
	$Timer.start()                    # Return to random behaviour
	
func go_timer():
	$Timer.start()

func _on_timer_timeout():
	$Timer.wait_time = randf_range(1, 4)
	x_dir = randi_range(-2,2)
	y_dir = randi_range(-2,2)
	x_vel = randi_range(30,51)
	y_vel = randi_range(30,51)
	if x_dir != 0 or y_dir != 0:
		velocity.y = y_vel * y_dir
		velocity.x = x_vel * x_dir

func baited():
	
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("o-o")
	$Timer_start_approach.start()

# Called when bait on range of fish
func _on_area_2d_body_entered(body):
	bait_body = body
	$Timer_take_bait.start()      # Start timer to randomly choose when fish takes the bait


func _on_area_2d_body_exited(body):
	print("goodbay")
	get_bait = false
	$AnimatedSprite2D.play("default")
	$Timer_take_bait.stop()           # Stop random timer
	$Timer.start()                    # Return to random behaviour


func _on_timer_start_approach_timeout():
	print("omw")
	get_bait = true

# Randomly chooses when to get baited
func _on_timer_take_bait_timeout():
	if randi_range(1,10) == 1 and bait_body is Hook_Simple:
		if not bait_body.being_targeted:
			if bait_body.velocity == Vector2(0,0):
				bait_body.being_targeted = true
				print("let's go")
				baited()
				$Timer_take_bait.stop()           # Stop random timer
				$Timer.stop()                     # Stop random behaviour
		else:
			bait_body = null
			$Timer_take_bait.stop()           # Stop random timer
