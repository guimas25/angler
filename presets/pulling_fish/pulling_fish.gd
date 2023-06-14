extends CharacterBody2D
class_name Fish_pulling

@export var SPEED = 500.0
const JUMP_VELOCITY = -400.0
const X_VELOCITY = 40
const Y_VELOCITY = 20
const CONST_RATE = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var x_vel = 0
var y_vel = 0
var x_dir = 1
var y_dir = 0

var bait_body
var get_bait = false

var pulling = false
var on_water = true

var dead = false

func _ready():
	$AnimatedSprite2D.play("default")
	randomize()
	velocity.x = randi_range(20,41)
	velocity.y = randi_range(20,41)

func _physics_process(delta):
	
	if is_on_floor() and not on_water:
		dead = true
	
	if get_bait and bait_body is Hook_Simple:
		velocity = Vector2(bait_body.position.x - position.x, bait_body.position.y - position.y)
		velocity = velocity.normalized() * randf_range(30,51)
	
	if pulling:
		$AnimatedSprite2D.flip_h = true
		if velocity.x > 0:
			$AnimatedSprite2D.flip_v = false
		else:
			$AnimatedSprite2D.flip_v = true
			
		if on_water:
			if Input.is_action_pressed("move_right"):
				velocity = velocity.rotated(2.5 * delta)
			if Input.is_action_pressed("move_left"):
				velocity = velocity.rotated(-2.5 * delta)
			velocity = velocity.normalized() * SPEED
			var pullDir = Vector2(velocity.x + position.x, velocity.y + position.y)
			$AnimatedSprite2D.look_at(pullDir)
		else:
			var pullDir = Vector2(velocity.x + position.x, velocity.y + position.y)
			$AnimatedSprite2D.look_at(pullDir)
			velocity.y = velocity.y + gravity/2 * delta
		
	else:
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	
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
	if not pulling:
		print("goodbay")
		get_bait = false
		$AnimatedSprite2D.play("default")
		$Timer_take_bait.stop()           # Stop random timer
		$Timer.start()                    # Return to random behaviour


func _on_timer_start_approach_timeout():
	get_bait = true

# Randomly chooses when to get baited
func _on_timer_take_bait_timeout():
	if randi_range(1,10) == 1 and bait_body is Hook_Simple and not bait_body.being_targeted:
		if bait_body.velocity == Vector2(0,0):
			bait_body.being_targeted = true
			print("let's go")
			baited()
			$Timer_take_bait.stop()           # Stop random timer
			$Timer.stop()                     # Stop random behaviour

func initiate_pull(pos):
	velocity = Vector2(1,0)
	var dirx = 1
	var diry = 1
	var lower = 0
	var higher = 359
	if pos.x < position.x:
		dirx = -1
	if pos.y > position.y:
		diry = -1
		
	if dirx == 1 and diry == -1:
		lower = PI
		higher = (3*(PI/2))
	elif dirx == -1 and diry == -1:
		lower = (3*(PI/2))
		higher = 2*PI
	elif dirx == -1 and diry == 1:
		lower = 0
		higher = PI/2
	elif dirx == 1 and diry == 1:
		lower = PI/2
		higher = PI
	
	var pulling_rotation = randf_range(lower, higher)
	print(pulling_rotation)
	velocity = velocity.rotated(pulling_rotation)
	velocity = velocity.normalized() * SPEED
	set_collision_layer_value(3, false)
	set_collision_layer_value(5, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(5, false)
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	pulling = true
	$AnimatedSprite2D.play("fell_for_it")
	$Timer.stop()
	$Timer_start_approach.stop()
	$Timer_take_bait.stop()
	
func get_on_water():
	on_water = true
	
func get_off_water():
	on_water = false
