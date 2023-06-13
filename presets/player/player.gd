extends CharacterBody2D

@export var SPEED_PUSH = 250
@export var SPEED = 350.0
@export var SPEED_WATER = 150.0
@export var JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.6

var coyote_time = 0.2
var jump_time = 0.0

var O2_timer = 10.0

var hp = 5 

var minigame_fishing = false
var pushing_box = false

@export var on_water = false

var hook_resource = preload("res://presets/hook/hook.tscn")

var hook_reference

var hook_on_scene = false

func _physics_process(delta):
	if not on_water:
		_on_land(delta)
	else:
		_on_water(delta)
	if Input.is_action_just_pressed("melee_action") and not $hitbox.visible:
		$hitbox.visible = true
		$hitbox.set_collision_mask_value(2, true)
		$Timers/Timer_attack.start()
		
	if minigame_fishing:
		if ($fish_meter/pointer.position.x >= $fish_meter/fish_hit_marker.position.x -8 \
		and $fish_meter/pointer.position.x < $fish_meter/fish_hit_marker.position.x - 4) or \
		($fish_meter/pointer.position.x > $fish_meter/fish_hit_marker.position.x \
		and $fish_meter/pointer.position.x <= $fish_meter/fish_hit_marker.position.x + 5):
			if Input.is_action_just_pressed("hook_action"):
				$fish_meter/fish_label.visible = true
				$fish_meter/fish_label.text = "OK!"
				if hook_reference is Hook_Simple:
					hook_reference.hook_reel()
					hook_reference.fish_follow = true
				stop_fishing()
		elif ($fish_meter/pointer.position.x >= $fish_meter/fish_hit_marker.position.x -4 \
		and $fish_meter/pointer.position.x <= $fish_meter/fish_hit_marker.position.x):
			if Input.is_action_just_pressed("hook_action"):
				$fish_meter/fish_label.visible = true
				$fish_meter/fish_label.text = "NICE CATCH!"
				if hook_reference is Hook_Simple:
					hook_reference.hook_reel()
					hook_reference.fish_follow = true
				stop_fishing()
		elif $fish_meter/pointer.position.x >= 22:
			$fish_meter/fish_label.visible = true
			$fish_meter/fish_label.text = "YIKES"
			hook_reference.being_targeted = false
			stop_fishing()
		elif Input.is_action_just_pressed("hook_action") and $fish_meter/pointer.position.x > 5:
			$fish_meter/fish_label.visible = true
			$fish_meter/fish_label.text = "YIKES"
			hook_reference.being_targeted = false
			stop_fishing()
		$fish_meter/pointer.move_and_slide()
	
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
	
	if direction > 0:
		$Sprite2D.flip_h = false
		$hitbox.position.x = 176
		$hitbox/AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$Sprite2D.flip_h = true
		$hitbox.position.x = -176
		$hitbox/AnimatedSprite2D.flip_h = true
		
	if Input.is_action_just_pressed("hook_action") and $Timers/Timer_fishing.time_left == 0 and not minigame_fishing:
		throw_hook(Vector2(100,-100))
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 30)

	if !pushing_box:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, 30)
		else:
			velocity.x = move_toward(velocity.x, 0, 50)
	else:
		velocity.x = direction * SPEED_PUSH
		
	if direction == 0:
		pushing_box = false
		
	move_and_slide()
	
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		if collider is Box2D:
			pushing_box = true
			print("collidion")
			collider.slide(-collision.get_normal() * (SPEED_PUSH))
	
	
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
	if not minigame_fishing:
		$fish_meter.visible = true
		$fish_meter/fish_label.visible = false
		$fish_meter/pointer.velocity.x = 20
		$fish_meter/pointer.position.x = 0
		minigame_fishing = true
	
func stop_fishing():
	$Timers/Timer_fishing.start()
	$fish_meter/pointer.velocity.x = 0
	hook_reference.being_targeted = false
	minigame_fishing = false
	
	
func throw_hook(x):
	if not hook_on_scene:
		var grabedInstance = hook_resource.instantiate()
		get_tree().get_root().get_child(0).add_child(grabedInstance)
		grabedInstance.hook_throw(position, velocity)
		hook_reference = grabedInstance
		hook_on_scene = true
	elif not minigame_fishing and hook_reference:
		hook_reference.hook_reel()
		
func _on_hitbox_body_entered(body):
	body.get_hurt()

func _on_timer_fishing_timeout():
	$fish_meter.visible = false
	$fish_meter/pointer.position.x = 0

func check_got_fish():
	return $fish_meter/fish_label.visible and ($fish_meter/fish_label.text == "OK!" \
			or  $fish_meter/fish_label.text == "NICE CATCH!")
