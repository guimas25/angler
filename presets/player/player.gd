extends CharacterBody2D

var SPEED_PUSH = 250
var SPEED = 350.0
var SPEED_WATER = 150.0
var JUMP_VELOCITY = -800.0

const CHAIN_PULL = 105
var chain_velocity := Vector2(0,0)
var hook_pos = Vector2()
var hooked = false
const rope_lenght = 500
var current_rope_lenght

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.6

var coyote_time = 0.2
var jump_time = 0.0

var O2_timer = 10.0

var hp = 5 

var minigame_fishing = false
var reelable = false
var pushing_box = false

@export var on_water = false

var hook_resource = preload("res://presets/hook/hook.tscn")
func _ready():
	current_rope_lenght = rope_lenght

var hook_reference

var hook_on_scene = false

var pulled_by_fish = false
var pulling_fish_ref
var pulling_vel_cooldown = false

func _process(delta):
	$Node2D.look_at(get_global_mouse_position())
		
func _physics_process(delta):
	var check_bait = weakref(hook_reference) # Try to get reference to the bait 

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
		if ($fish_meter/pointer.position.x >= $fish_meter/fish_hit_marker.position.x -8 \
		and $fish_meter/pointer.position.x < $fish_meter/fish_hit_marker.position.x - 4) or \
		($fish_meter/pointer.position.x > $fish_meter/fish_hit_marker.position.x \
		and $fish_meter/pointer.position.x <= $fish_meter/fish_hit_marker.position.x + 5):
			if Input.is_action_just_pressed("hook_action"):
				$fish_meter/fish_label.visible = true
				$fish_meter/fish_label.text = "OK!"
				if check_bait.get_ref():                      # If it was able to, object still on the loose!
					if hook_reference is Hook_Simple:
						hook_reference.fish_follow = true
						if hook_reference.fish_caught is Fish_pulling:
							hook_reference.hook_done()
						else:
							hook_reference.hook_reel()
				stop_fishing()
		elif ($fish_meter/pointer.position.x >= $fish_meter/fish_hit_marker.position.x -4 \
		and $fish_meter/pointer.position.x <= $fish_meter/fish_hit_marker.position.x):
			if Input.is_action_just_pressed("hook_action"):
				$fish_meter/fish_label.visible = true
				$fish_meter/fish_label.text = "NICE CATCH!"
				if check_bait.get_ref():                      # If it was able to, object still on the loose!
					if hook_reference is Hook_Simple:
						hook_reference.fish_follow = true
						if hook_reference.fish_caught is Fish_pulling:
							hook_reference.hook_done()
						else:
							hook_reference.hook_reel()
				stop_fishing()
		elif $fish_meter/pointer.position.x >= 22:
			$fish_meter/fish_label.visible = true
			$fish_meter/fish_label.text = "YIKES"
			if check_bait.get_ref():                      # If it was able to, object still on the loose!
				hook_reference.being_targeted = false
				stop_fishing()
		elif Input.is_action_just_pressed("hook_action") and $fish_meter/pointer.position.x > 5:
			$fish_meter/fish_label.visible = true
			$fish_meter/fish_label.text = "YIKES"
			if check_bait.get_ref():                      # If it was able to, object still on the loose!
				hook_reference.being_targeted = false
				stop_fishing()
		$fish_meter/pointer.move_and_slide()
	
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
	
	hook()
	queue_redraw()
	if hooked:
		swing(delta)
		velocity *= 0.975 # swing speed

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
		
	if Input.is_action_just_pressed("hook_action") and $Timers/Timer_fishing.time_left == 0 and not minigame_fishing and not reelable:
		throw_hook()
	
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
			print("collision")
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
	
	
func throw_hook():
	if not hook_on_scene:
		var hook_instance = hook_resource.instantiate()
		hook_instance.position = get_global_position()
		hook_instance.velocity = Vector2(300, 0).rotated($Node2D.rotation)
		hook_instance.hook_throw()
		hook_reference = hook_instance
		get_tree().get_root().add_child(hook_instance)
		#get_tree().get_root().get_child(0).add_child(grabedInstance)
		hook_on_scene = true
		
	elif not minigame_fishing and hook_reference:
		hook_reference.hook_reel()
		
func _on_hitbox_body_entered(body):
	body.get_hurt()

func _on_timer_fishing_timeout():
	$fish_meter.visible = false
	$fish_meter/pointer.position.x = 0

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

func get_hook_pos():
	for raycast in $GrapplingHook.get_children():
		if raycast.is_colliding():
			return raycast.get_collision_point()

func swing(delta):
	var radius = global_position - hook_pos
	if velocity.length() < 0.01 or radius.length() < 10: return
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var rad_vel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -rad_vel
	
	if global_position.distance_to(hook_pos) > current_rope_lenght:
		global_position = hook_pos + radius.normalized() * current_rope_lenght
	
	velocity += (hook_pos - global_position).normalized() * 15000 * delta


func _draw():
	var pos = global_position
	
	if hooked:
		draw_line(Vector2(0,0), to_local(hook_pos), Color(1,1,1), 0.5, true)
	else:
		return
		
		var colliding = $GrapplingHook.is_colliding()
		var collide_point = $GrapplingHook.get_collision_point()
		
		if colliding and pos.distance_to(collide_point) < rope_lenght:
			draw_line(Vector2(0,0), to_local(collide_point), Color(0,0,0), 0.5, true)
			
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
