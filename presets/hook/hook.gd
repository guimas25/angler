extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_VELOCITY_Y = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 0

var on_water = false

var hook_height = 0

func _physics_process(delta):
	if !on_water:
		if velocity.y <= MAX_VELOCITY_Y:
			velocity.y += (gravity/2) * delta
	elif on_water:
		velocity.x = move_toward(velocity.x, 0, 4)
		velocity.y = move_toward(velocity.y, 0, 20)
		position.y = move_toward(position.y, hook_height, 1.5)
	move_and_slide()
	
func hook_throw(pos, vel):
	on_water = false
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	self.position = pos
	velocity.x = 100
	velocity.y = -300

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
	


func _on_fish_detector_body_entered(body):
	# Make minigame start here, use custom signal do connect with game manager
	pass
