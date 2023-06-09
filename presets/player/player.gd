extends CharacterBody2D

@export var SPEED_PUSH = 250
@export var SPEED = 350.0
@export var SPEED_WATER = 150.0
@export var JUMP_VELOCITY = -800.0

signal throw_signal(pos, vel)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.6

var coyote_time = 0.2
var jump_time = 0.0

var O2_timer = 10.0

var hp = 5 

var pushing_box = false

@export var on_water = false



func _physics_process(delta):
	if not on_water:
		_on_land(delta)
	else:
		_on_water(delta)
	if Input.is_action_just_pressed("melee_action") and not $hitbox.visible:
		$hitbox.visible = true
		$hitbox.set_collision_mask_value(2, true)
		$Timers/Timer_attack.start()

	
func _on_water(delta):
	var direction_h = Input.get_axis("move_left", "move_right")
	var direction_v = Input.get_axis("move_up", "move_down")
	
	if direction_h == 1:
		$Sprite2D.flip_h = false
	elif direction_h == -1:
		$Sprite2D.flip_h = true
	
	if not is_on_floor() and direction_v == 0:
		velocity.y = gravity/2 * delta
		direction_v = velocity.y
	
	velocity.x = move_toward(velocity.x, direction_h * SPEED, 30)
	velocity.y = move_toward(velocity.y, direction_v * SPEED, 30)
	
	move_and_slide()
	
func _on_land(delta):
	# Add the gravity.
	if not is_on_floor():
		coyote_time = coyote_time - delta
		velocity.y += gravity * delta
	else:
		coyote_time = 0.2
		
	# Handle Jump.
	jump_time = jump_time - delta
	if Input.is_action_just_pressed("move_jump"):
		jump_time = 0.2
	
	if jump_time > 0 and coyote_time > 0:
		coyote_time = 0.0
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("move_jump") and velocity.y < 0:
		velocity.y = velocity.y/2

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	direction = Input.get_axis("move_left", "move_right")
	
	if direction == 1:
		$Sprite2D.flip_h = false
		$hitbox.position.x = 176
		$hitbox/AnimatedSprite2D.flip_h = false
	elif direction == -1:
		$Sprite2D.flip_h = true
		$hitbox.position.x = -176
		$hitbox/AnimatedSprite2D.flip_h = true
		
	if Input.is_action_just_pressed("hook_action"):
		throw_hook(Vector2(100,-100))
		start_fishing()

	if !pushing_box:
		print("Entrei")
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, 30)
		else:
			velocity.x = move_toward(velocity.x, 0, 50)
	else:
		velocity.x = direction * SPEED_PUSH
		
	if direction == 0:
		pushing_box = false
		
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if collision.get_collider() is Box2D:
			pushing_box = true
			print("collidion")
			collision.get_collider().slide(-collision.get_normal() * (SPEED_PUSH))
		check_box_collision(velocity, direction)
	
	
func get_on_water():
	on_water = true
	if velocity.y > 0:
		velocity.y = 400.0

func get_off_water():
	on_water = false
	if Input.is_action_pressed("move_up"):
		velocity.y = -800.0

func _on_timer_attack_timeout():
	$hitbox.visible = false
	$hitbox.set_collision_mask_value(2, false)

func start_fishing():
	pass
	
func throw_hook(x):
	emit_signal("throw_signal", self.position, x)

func _on_hitbox_body_entered(body):
	body.get_hurt()

func check_box_collision(vel: Vector2, direction: int) -> void:
	if vel.y != 0:
		return
	var box : = get_last_slide_collision().get_collider() as Box
	var box_collision = get_last_slide_collision()
	if box:
		#pushing_box = true
		#velocity.x = -box_collision.get_normal().x * 200
		box.apply_impulse(-box_collision.get_normal() * (SPEED/2))
		print(velocity.x)
		print("collide")
		print("ola")
		box.push(vel)

