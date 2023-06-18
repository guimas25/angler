extends CharacterBody2D
class_name Hook_Simple

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_VELOCITY_Y = 1000

var player_ref
var fish_caught
var origin

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hook_height = 0

var on_water = false
var reeling = false
var fish_follow = false
var being_targeted = false
var floating_angle = 0
var result_fish = false

func _ready():
	#player_ref = get_tree().get_root().get_child(0).get_node("Player")
	#print(player_ref)
	pass

func _physics_process(delta):
	look_at(Vector2(position.x + velocity.x, position.y + velocity.y))
	origin = player_ref.position
	if !on_water and !reeling:
		if velocity.y <= MAX_VELOCITY_Y:
			velocity.y += (gravity/2) * delta
	elif on_water:
		velocity.x = move_toward(velocity.x, 0, 30)
		velocity.y = move_toward(velocity.y, 0, 15)
		position.y = move_toward(position.y, hook_height, 1.5)
		rotation = move_toward(rotation, floating_angle, 0.5)
	elif reeling:
		velocity = Vector2(0,0)
		position = position.lerp(origin, 0.3)
		if position.x >= origin.x - 20 and position.x <= origin.x + 20 and position.y >= origin.y - 20 and position.y <= origin.y + 20:
			hook_done(result_fish)
		
	if fish_follow:
		fish_caught.position = position
	move_and_slide()
	
func hook_throw():
	on_water = false
	
func hook_reel(result):
	if not reeling:
		set_collision_layer_value(9, false)
		set_collision_mask_value(9, false)
		on_water = false
		reeling = true
		being_targeted = true
		result_fish = true

func _on_area_2d_area_entered(area): 
	if area is Water_body and not reeling:
		if self.velocity.y > 0:
			floating_angle = PI/2
		elif self.velocity.y < 0:
			floating_angle = -PI/2
		hook_height = self.position.y
		on_water = true
		set_collision_layer_value(4, true)
		set_collision_mask_value(4, true)

func _on_area_2d_fishing_area_entered(body):
	if(velocity == Vector2(0,0) and body.get_parent().get_bait):
		fish_caught = body.get_parent()
		fish_caught.hooked()
		player_ref.start_fishing()
	else:
		$Timer_on_off.start()
		$Area2D_fishing.set_collision_layer_value(5, false)
		$Area2D_fishing.set_collision_mask_value(5, false)

func hook_done(result):
	var check_bait = weakref(fish_caught)         # Try to get reference to the fish 
	if check_bait.get_ref() and result:                      # If it was able to, object still on the loose!
		if fish_follow:
			if (fish_caught is Fish_simple):
				fish_caught.queue_free()
			elif (fish_caught is Fish_pulling):
				fish_caught.initiate_pull(player_ref.position)
				fish_follow = false
				player_ref.initiate_pulling(fish_caught)
	player_ref.hook_on_scene = false
	self.queue_free()

func _on_timer_on_off_timeout():
	$Area2D_fishing.set_collision_layer_value(5, true)
	$Area2D_fishing.set_collision_mask_value(5, true)
