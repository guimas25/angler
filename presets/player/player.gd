extends CharacterBody2D


@export var SPEED = 350.0
@export var JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.6

var coyote_time = 0.2
var jump_time = 0.0

var O2_timer = 10.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		coyote_time = coyote_time - delta
		velocity.y += gravity * delta
	else:
		coyote_time = 0.2
		
	# Handle Jump.
	jump_time = jump_time - delta
	if Input.is_action_just_pressed("ui_accept"):
		jump_time = 0.2
	
	if jump_time > 0 and coyote_time > 0:
		coyote_time = 0.0
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = velocity.y/2

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	direction = Input.get_axis("ui_left", "ui_right")
	
	
	if direction == 1:
		$Sprite2D.flip_h = false
	elif direction == -1:
		$Sprite2D.flip_h = true
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 30)
		#$SpriteSTUPID/AnimationPlayer.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
	move_and_slide()
