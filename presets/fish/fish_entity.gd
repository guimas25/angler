extends CharacterBody2D


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

var bait_position = Vector2(0,0)

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

	move_and_slide()

func hooked():
	$Timer.stop()
	velocity.x = 0
	velocity.y = 0
	
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

func baited(pos):
	bait_position = pos
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("o-o")
	$Timer_start_approach.start()

func _on_area_2d_body_entered(body):
	if(body.velocity == Vector2(0,0)):
		baited(body.position)
		$Timer.stop()


func _on_area_2d_body_exited(body):
	print("goodbay")
	$Timer.start()


func _on_timer_start_approach_timeout():
	print("omw")
	var bait_direction = Vector2(bait_position.x - position.x, bait_position.y - position.y)
	velocity = bait_direction.normalized() * randi_range(30,51)
