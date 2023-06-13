extends CharacterBody2D
class_name Hook_Simple

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_VELOCITY_Y = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 0

var on_water = false

var hook_height = 0

var thrown = false

var reeling = false
var origin = null
var player_ref

var fish_caught

var fish_follow = false

var being_targeted = false

var being_reeled = false

signal start_minigame(body)
signal reelable

func _process(delta):
	if(velocity == Vector2(0,0) and thrown and on_water):
		emit_signal("reelable")

func _ready():
	player_ref = get_tree().get_root().get_child(0).get_node("Player")
	print(player_ref)

func _physics_process(delta):
	if !on_water and !reeling and thrown:
		if velocity.y <= MAX_VELOCITY_Y:
			velocity.y += (gravity/2) * delta
	elif on_water:
		velocity.x = move_toward(velocity.x, 0, 4)
		velocity.y = move_toward(velocity.y, 0, 20)
		position.y = move_toward(position.y, hook_height, 1.5)
	elif reeling:
		position.x = move_toward(position.x, origin.x, 4)
		position.y = move_toward(position.y, origin.y, 4)
		if position == origin:
			reeling = false
			thrown = false
			self.visible = false
		
	if fish_follow:
		fish_caught.position = position
	move_and_slide()
	
func hook_throw(pos, vel):
	self.visible = true
	if not thrown:
		thrown = true
		on_water = false
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		self.position = pos
		velocity.x = 100
		velocity.y = -300
	
func hook_reel(pos):
	on_water = false
	origin = pos
	reeling = true
	being_targeted = true
	being_reeled = true
	$Timer.start()

func get_on_water():
	pass

func get_off_water():
	pass

# On area2d entered for water, area_entered, for fish, body_entered
# When area_entered happen, call get_parent().start_fishing()

func _on_area_2d_area_entered(area):
	if "water_body" in area.name: # TODO might fuck up in future, need change
		hook_height = self.position.y
		on_water = true
		
		#get_parent().start_fishing()


func _on_area_2d_fishing_body_entered(body):
	if(velocity == Vector2(0,0) and body.get_bait):
		fish_caught = body
		body.hooked()
		player_ref.start_fishing()


func _on_timer_timeout():
	if fish_follow and (fish_caught is Fish_simple or fish_caught is Fish_pulling):
		fish_caught.queue_free()
	player_ref.hook_on_scene = false
	self.queue_free()
