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

func _ready():
	player_ref = get_tree().get_root().get_child(0).get_node("Player")
	print(player_ref)

func _physics_process(delta):
	look_at(Vector2(position.x + velocity.x, position.y + velocity.y))
	origin = player_ref.position
	if !on_water and !reeling:
		if velocity.y <= MAX_VELOCITY_Y:
			velocity.y += (gravity/2) * delta
	elif on_water:
		velocity.x = move_toward(velocity.x, 0, 20)
		velocity.y = move_toward(velocity.y, 0, 10)
		position.y = move_toward(position.y, hook_height, 1.5)
		rotation = move_toward(rotation, PI/2, 0.5)
	elif reeling:
		velocity = Vector2(0,0)
		position = position.lerp(origin, 0.3)
		if position.x >= origin.x - 20 and position.x <= origin.x + 20 and position.y >= origin.y - 20 and position.y <= origin.y + 20:
			hook_done()
		
	if fish_follow:
		fish_caught.position = position
	move_and_slide()
	
func hook_throw():
	on_water = false
	
func hook_reel():
	if not reeling:
		on_water = false
		reeling = true
		being_targeted = true

func get_on_water():
	pass

func get_off_water():
	pass

# On area2d entered for water, area_entered, for fish, body_entered
# When area_entered happen, call get_parent().start_fishing()

func _on_area_2d_area_entered(area): 
	if area is Water_body and not reeling:
		hook_height = self.position.y
		on_water = true
		set_collision_layer_value(4, true)
		set_collision_mask_value(4, true)
		
		#get_parent().start_fishing()


func _on_area_2d_fishing_body_entered(body):
	if(velocity == Vector2(0,0) and body.get_bait):
		fish_caught = body
		body.hooked()
		player_ref.start_fishing()
	else:
		$Timer_on_off.start()
		$Area2D_fishing.set_collision_layer_value(5, false)
		$Area2D_fishing.set_collision_mask_value(5, false)

func hook_done():
	var check_bait = weakref(fish_caught)         # Try to get reference to the fish 
	if check_bait.get_ref():                      # If it was able to, object still on the loose!
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
