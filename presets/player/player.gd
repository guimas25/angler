extends CharacterBody2D

@export var SPEED_PUSH = 250
@export var SPEED = 350.0
@export var SPEED_WATER = 150.0
@export var JUMP_VELOCITY = -800.0
@export var MAX_ROPE_LENGHT = 500

var hook_pos = Vector2()
var hooked = false
const rope_lenght = 500
var current_rope_lenght
var just_grappled = true
var pulling = false

var caught_fish = [1, 4, 5]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.6

var coyote_time = 0.2
var jump_time = 0.0

var O2_timer = 10.0

var hp = 5 
var minigame_2_round_counter = 0 # Used to count rounds for minigame 2
var minigame_2_required = 0 # number of rounds to win
var minigame_2_combo = 0 # Use for funny combo
var minigame_fishing = false
var reelable = false
var pushing_box = false

@export var on_water = false

var hook_resource = preload("res://presets/hook/hook.tscn")
func _ready():
	current_rope_lenght = rope_lenght

var hook_reference
var hook_max_distance = 300 # Max distance between the player and the hook
var hook_on_scene = false

var pulled_by_fish = false
var pulling_fish_ref
var pulling_vel_cooldown = false

func _physics_process(delta):
	var check_bait = weakref(hook_reference) # Try to get reference to the bait 
	
	# Check if player is fishing, if yes nerf speed
	if hook_on_scene:
		var hook_distance = hook_reference.position - position
		SPEED = 250 - 200 * (hook_distance.length() / hook_max_distance)
		JUMP_VELOCITY = -400.0
		if hook_distance.length() >= hook_max_distance:  # If player goes beyond max distance, reel back
			stop_immediate_fishing()
	else:
		SPEED = 350
		JUMP_VELOCITY = -800.0
	
	if pulled_by_fish:
		if pulling_fish_ref.dead:
			stop_pulling()
		else:
			var speed_pull = pulling_fish_ref.SPEED
			var pulling_velocity = Vector2(0.0,0.0)
			pulling_velocity.x = pulling_fish_ref.position.x - position.x
			pulling_velocity.y = pulling_fish_ref.position.y - position.y
				
			speed_pull = pulling_fish_ref.SPEED * pulling_velocity.length()/100
			
			velocity = pulling_velocity.normalized() * speed_pull
			var pullDir = Vector2(velocity.x + position.x, velocity.y + position.y)
			$Sprite2D.look_at(pullDir)
		move_and_slide()
	elif not on_water:
		_on_land(delta)
	else:
		_on_water(delta)
	if Input.is_action_just_pressed("melee_action") and not $hitbox.visible:
		$hitbox.visible = true
		$hitbox.set_collision_mask_value(2, true)
		$Timers/Timer_attack.start()
		
	if minigame_fishing:
		if check_bait.get_ref():
			var check_fish = weakref(hook_reference.fish_caught)
			if check_fish.get_ref():
				if hook_reference.fish_caught is Fish_simple:
					fishing_minigame_1(check_bait)
				elif hook_reference.fish_caught is Fish_pulling:
					fishing_minigame_2(check_bait)
	
func _on_water(delta):
	if hooked:
		queue_redraw()
		hooked = false
	
	var direction_h = Input.get_axis("move_left", "move_right")
	var direction_v = Input.get_axis("move_up", "move_down")
	
	if direction_h == 1:
		$Sprite2D.flip_h = false
	elif direction_h == -1:
		$Sprite2D.flip_h = true
	
	if not is_on_floor() and direction_v == 0:
		velocity.y = gravity/2 * delta
		direction_v = velocity.y
	
	velocity.x = move_toward(velocity.x, direction_h * SPEED_WATER, 30)
	velocity.y = move_toward(velocity.y, direction_v * SPEED_WATER, 30)
	
	move_and_slide()
	
func _on_land(delta):
	hook()
	queue_redraw()
	if hooked:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			print("here")
			velocity += (hook_pos - global_position).normalized() * 15000000 * delta
		swing(delta)
		just_grappled = false
		velocity *= 0.975 # swing speed
	
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x += direction * 20 * 0.975
	
	# Add the gravity.
	else:
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
		
		if Input.is_action_just_pressed("inventory_open") and not minigame_fishing:
			show_inventory()

		if !pushing_box:
			if direction:
				velocity.x = move_toward(velocity.x, direction * SPEED, 30)
			else:
				velocity.x = move_toward(velocity.x, 0, 50)
		else:
			velocity.x = direction * SPEED_PUSH
			
		if direction == 0:
			pushing_box = false
			
		
		
		for index in get_slide_collision_count():
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if collider is Box2D:
				pushing_box = true
				collider.slide(-collision.get_normal() * (SPEED_PUSH))
	move_and_slide()	
	
func get_on_water():
	on_water = true
	stop_immediate_fishing()
	if velocity.y > 0:
		velocity.y = 200.0

func get_off_water():
	on_water = false
	if Input.is_action_pressed("move_up"):
		velocity.y = -200.0

func _on_timer_attack_timeout():
	$hitbox.visible = false
	$hitbox.set_collision_mask_value(2, false)

func start_fishing():
	if not minigame_fishing:
		$fish_meter.visible = true
		$fish_meter/fish_label.visible = false
		minigame_fishing = true
		minigame_randomizer()
		minigame_2_round_counter = 0
		minigame_2_required = randi_range(2,5)
		$fish_meter/round1.visible = false
		$fish_meter/round2.visible = false
		$fish_meter/round3.visible = false
		$fish_meter/round4.visible = false
		$fish_meter/round5.visible = false
			
		# RANDOM MINIGAMES BETWEEN 1 and 2 TODO
		
func stop_fishing():
	$Timers/Timer_fishing.start()
	$fish_meter/pointer.velocity.x = 0
	if hook_on_scene:
		hook_reference.being_targeted = false
	minigame_fishing = false
	# Clean up minigame 2
	minigame_2_round_counter = 0
	minigame_2_combo = 0
	
func stop_immediate_fishing():
	$fish_meter/pointer.velocity.x = 0
	if hook_on_scene:
		hook_reference.being_targeted = false
		hook_reference.hook_reel(false)
	minigame_fishing = false
	_on_timer_fishing_timeout()
	
func throw_hook():
	if not hook_on_scene:
		var grabedInstance = hook_resource.instantiate()
		get_tree().get_root().get_child(0).add_child(grabedInstance)
		grabedInstance.hook_throw(position, velocity)
		hook_reference = grabedInstance
		hook_on_scene = true
	elif not minigame_fishing and hook_reference:
		hook_reference.hook_reel(false)
		
func _on_hitbox_body_entered(body):
	body.get_hurt()

func _on_timer_fishing_timeout():
	$fish_meter.visible = false
	$fish_meter/pointer.position.x = 0
	# Clean Up minigame 2
	$fish_meter/round1.play("yellow")
	$fish_meter/round2.play("yellow")
	$fish_meter/round3.play("yellow")
	$fish_meter/round4.play("yellow")
	$fish_meter/round5.play("yellow")
	$fish_meter/round1.visible = false
	$fish_meter/round2.visible = false
	$fish_meter/round3.visible = false
	$fish_meter/round4.visible = false
	$fish_meter/round5.visible = false

func _on_hook_reelable():
	reelable = true
func check_got_fish():
	return $fish_meter/fish_label.visible and ($fish_meter/fish_label.text == "OK!" \
			or  $fish_meter/fish_label.text == "NICE CATCH!")
			
func hook():
	$GrapplingHook.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("left_click"):
		hook_pos = get_hook_pos()
		if hook_pos:
			hooked = true
			current_rope_lenght = global_position.distance_to(hook_pos)
	if Input.is_action_just_released("left_click") and hooked:
		hooked = false
		just_grappled = true
		pulling = false

func get_hook_pos():
	for raycast in $GrapplingHook.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()

func swing(delta):
	var radius = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 20: return
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var angle_to_floor = Vector2(1,0).angle_to(radius)
	var rad_vel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_vel
	
	if(angle_to_floor < 0 and angle_to_floor > -PI and just_grappled):
		pulling = true
	elif pulling:
		velocity += (hook_pos - global_position).normalized() * 55000 * delta
	if(angle_to_floor > 0):
		pulling = false
		if(Input.is_action_pressed("move_up")):
			velocity += (hook_pos - global_position).normalized() * 3500 * delta
			current_rope_lenght = (hook_pos - global_position).length()
		if(Input.is_action_pressed("move_down")):
			if(current_rope_lenght < MAX_ROPE_LENGHT):
				velocity -= (hook_pos - global_position).normalized() * 3500 * delta
				current_rope_lenght = (hook_pos - global_position).length()
		if(is_on_floor()):
			velocity += (hook_pos - global_position).normalized() * 1500 * delta
		#velocity += (hook_pos - global_position).normalized() * 1500 * delta
	
	if global_position.distance_to(hook_pos) > current_rope_lenght:
		global_position = hook_pos + radius.normalized() * current_rope_lenght
	print(current_rope_lenght)
func _draw():
	var pos = global_position
	
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(1,1,1), 0.25, true)
	else:
		return
		
		var colliding = $GrapplingHook.is_colliding()
		var collide_point = $GrapplingHook.get_collision_point()
		
		if colliding and pos.distance_to(collide_point) < rope_lenght:
			draw_line(Vector2(0,0), to_local(collide_point), Color(0,0,0), 0.5, true)

func show_inventory():
	$Inventory.visible = !$Inventory.visible

func update_inventory():
	$Inventory/ColorRect/Sprite2D/FishLabel.text = str(caught_fish[0])
	$Inventory/ColorRect/Sprite2D2/FishLabel.text = str(caught_fish[1])
	$Inventory/ColorRect/Sprite2D3/FishLabel.text = str(caught_fish[2])
			
func initiate_pulling(x):
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(6, false)
	set_collision_mask_value(6, false)
	pulled_by_fish = true
	pulling_fish_ref = x
	
func stop_pulling():
	pulled_by_fish = false
	pulling_fish_ref.queue_free()
	$Sprite2D.rotation = 0.0
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)


func _on_timer_pull_cooldown_timeout():
	pulling_vel_cooldown = false
	
func fishing_minigame_1(check_bait):
	# Get coordinates for yellow areas
	var left_hit_low = $fish_meter/fish_hit_marker2.position.x - 10 * $fish_meter/fish_hit_marker2.scale.x
	var left_hit_high = $fish_meter/fish_hit_marker2.position.x
	var right_hit_low = $fish_meter/fish_hit_marker3.position.x
	var right_hit_high =  $fish_meter/fish_hit_marker3.position.x + 10 * $fish_meter/fish_hit_marker3.scale.x
	var center_hit_low = $fish_meter/fish_hit_marker.position.x - 5 *  $fish_meter/fish_hit_marker.scale.x
	var center_hit_high = $fish_meter/fish_hit_marker.position.x + 5  *  $fish_meter/fish_hit_marker.scale.x
	
	if ($fish_meter/pointer.position.x >= left_hit_low and $fish_meter/pointer.position.x < left_hit_high) or \
		($fish_meter/pointer.position.x > right_hit_low and $fish_meter/pointer.position.x <= right_hit_high):
			if Input.is_action_just_pressed("hook_action"):
				$fish_meter/fish_label.visible = true
				$fish_meter/fish_label.text = "OK!"
				if check_bait.get_ref():                      # If it was able to, object still on the loose!
					if hook_reference is Hook_Simple:
						hook_reference.fish_follow = true
						if hook_reference.fish_caught is Fish_pulling:
							hook_reference.hook_done(true)
						else:
							hook_reference.hook_reel(true)
				stop_fishing()
	elif ($fish_meter/pointer.position.x >= center_hit_low\
	and $fish_meter/pointer.position.x <= center_hit_high):
		if Input.is_action_just_pressed("hook_action"):
			$fish_meter/fish_label.visible = true
			$fish_meter/fish_label.text = "NICE CATCH!"
			if check_bait.get_ref():                      # If it was able to, object still on the loose!
				if hook_reference is Hook_Simple:
					hook_reference.fish_follow = true
					if hook_reference.fish_caught is Fish_pulling:
						hook_reference.hook_done(true)
					else:
						hook_reference.hook_reel(true)
			stop_fishing()
	elif $fish_meter/pointer.position.x >= 82 \
	or Input.is_action_just_pressed("hook_action") and $fish_meter/pointer.position.x > 10:
		$fish_meter/fish_label.visible = true
		$fish_meter/fish_label.text = "YIKES"
		if check_bait.get_ref():                      # If it was able to, object still on the loose!
			hook_reference.being_targeted = false
			hook_reference.hook_reel(false)
			stop_fishing()
	$fish_meter/pointer.move_and_slide()
	
	
func fishing_minigame_2(check_bait):
	$fish_meter/round1.visible = true
	$fish_meter/round2.visible = true
	if minigame_2_required >= 3:
		$fish_meter/round3.visible = true
	if minigame_2_required >= 4:
		$fish_meter/round4.visible = true
	if minigame_2_required >= 5:
		$fish_meter/round5.visible = true
	# Get coordinates for yellow areas
	var left_hit_low = $fish_meter/fish_hit_marker2.position.x - 10 * $fish_meter/fish_hit_marker2.scale.x
	var left_hit_high = $fish_meter/fish_hit_marker2.position.x
	var right_hit_low = $fish_meter/fish_hit_marker3.position.x
	var right_hit_high =  $fish_meter/fish_hit_marker3.position.x + 10 * $fish_meter/fish_hit_marker3.scale.x
	var center_hit_low = $fish_meter/fish_hit_marker.position.x - 5 *  $fish_meter/fish_hit_marker.scale.x
	var center_hit_high = $fish_meter/fish_hit_marker.position.x + 5  *  $fish_meter/fish_hit_marker.scale.x
	# If pointer in yellow area, add one round, make round ball green, proceed
	if ($fish_meter/pointer.position.x >= left_hit_low and $fish_meter/pointer.position.x < left_hit_high) or \
		($fish_meter/pointer.position.x > right_hit_low and $fish_meter/pointer.position.x <= right_hit_high):
		if Input.is_action_just_pressed("hook_action"):
			$fish_meter/fish_label.visible = true
			minigame_2_combo = 0
			$fish_meter/fish_label.text = "Almost...!"
			minigame_2_round_counter -= 1
			minigame_2_round_counter = clamp(minigame_2_round_counter, 0, 5)
			match minigame_2_round_counter:
				0:
					$fish_meter/round1.play("yellow")
				1:
					$fish_meter/round2.play("yellow")
				2:
					$fish_meter/round3.play("yellow")
				3:
					$fish_meter/round4.play("yellow")
				4:
					$fish_meter/round5.play("yellow")
			minigame_randomizer()
	# Check if hit was on center
	elif ($fish_meter/pointer.position.x >= center_hit_low and $fish_meter/pointer.position.x <= center_hit_high):
		if Input.is_action_just_pressed("hook_action"):
			$fish_meter/fish_label.visible = true
			minigame_2_combo = minigame_2_combo + 1
			minigame_2_round_counter += 1
			minigame_2_round_counter = clamp(minigame_2_round_counter, 0, 5)
			match minigame_2_combo:
				1:
					$fish_meter/round1.play("green")
					$fish_meter/fish_label.text = "1x GOOD!"
				2:
					$fish_meter/round2.play("green")
					$fish_meter/fish_label.text = "2x GREAT"
				3:
					$fish_meter/round3.play("green")
					$fish_meter/fish_label.text = "3x AWESOME"
				4:
					$fish_meter/round4.play("green")
					$fish_meter/fish_label.text ="4x OUTSTANDING"
				5:
					$fish_meter/round5.play("green")
					$fish_meter/fish_label.text = "5x AMAZING!!!!"
					
			match minigame_2_round_counter:
				1:
					$fish_meter/round1.play("green")
				2:
					$fish_meter/round2.play("green")
				3:
					$fish_meter/round3.play("green")
				4:
					$fish_meter/round4.play("green")
				5:
					$fish_meter/round5.play("green")
			if minigame_2_round_counter >= minigame_2_required:
				if check_bait.get_ref():                      # If it was able to, object still on the loose!
					if hook_reference is Hook_Simple:
						hook_reference.fish_follow = true
						if hook_reference.fish_caught is Fish_pulling:
							hook_reference.hook_done(true)
						else:
							hook_reference.hook_reel(true)
				minigame_2_round_counter = 0
				stop_fishing()
			else:
				minigame_randomizer()
	elif $fish_meter/pointer.position.x >= 82 \
	or (Input.is_action_just_pressed("hook_action") and $fish_meter/pointer.position.x > 5):
		$fish_meter/fish_label.visible = true
		minigame_2_combo = 0
		$fish_meter/fish_label.text = "YIKES"
		minigame_2_round_counter += 1
		match minigame_2_round_counter:
			1:
				$fish_meter/round1.play("red")
			2:
				$fish_meter/round2.play("red")
			3:
				$fish_meter/round3.play("red")
			4:
				$fish_meter/round4.play("red")
			5:
				$fish_meter/round5.play("red")
		if check_bait.get_ref():                      # If it was able to, object still on the loose!
			hook_reference.being_targeted = false
			hook_reference.hook_reel(false)
			stop_fishing()
	$fish_meter/pointer.move_and_slide()

func minigame_randomizer():
	$fish_meter/pointer.velocity.x = randf_range(50, 80) # change later
	$fish_meter/pointer.position.x = 2
	var rand_scale = randf_range(0.5, 1.5)
	$fish_meter/fish_hit_marker.position.x = randf_range(34, 59)
	$fish_meter/fish_hit_marker.scale.x = randf_range(0.5, 1)
	$fish_meter/fish_hit_marker2.scale.x = rand_scale
	$fish_meter/fish_hit_marker3.scale.x = rand_scale
	$fish_meter/fish_hit_marker2.position.x = $fish_meter/fish_hit_marker.position.x - 5 * $fish_meter/fish_hit_marker.scale.x
	$fish_meter/fish_hit_marker3.position.x = $fish_meter/fish_hit_marker.position.x + 5 * $fish_meter/fish_hit_marker.scale.x
