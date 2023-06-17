extends CharacterBody2D
class_name Box2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var SPEED_PUSH = 250


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var position_to_stay = Vector2()
var position_to_push = Vector2()
var push_collider
var getting_pulled = false
var stay_put = false
var stuck_to_box = false
var player_pushing = false

var relative_pos = Vector2.ZERO

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not stay_put and not stuck_to_box:
		velocity.y += gravity * delta
	
	velocity.x = move_toward(velocity.x, 0, 50)
		
	if stay_put:
		global_position.x = position_to_stay.x
		global_position.y = position_to_stay.y - 1
	
	if stuck_to_box and push_collider and not getting_pulled and not player_pushing:
		global_position.x = push_collider.global_position.x + relative_pos.x
		global_position.y = push_collider.global_position.y - 36
	
	if getting_pulled and stuck_to_box:
		relative_pos = global_position - push_collider.global_position
	
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if collider is Box2D:
			#box pushed box
			if(normal.y == 0):
				collision.get_collider().slide(-collision.get_normal() * (SPEED_PUSH/2))
		elif collider is Player: #check if player is underneat
			if(normal.y == -1):
				if !stay_put:
					stay_put = true
					position_to_stay = global_position
					
	move_and_slide()

func slide(vector):
	velocity.x = vector.x

func _on_area_2d_body_entered(body):
	if (body is Box2D and body != self):
		relative_pos.x = global_position.x - body.global_position.x
		relative_pos.y = global_position.y - body.global_position.y
		stuck_to_box = true
		push_collider = body

func _on_area_2d_body_exited(body):
	print("left")
	if(body is Box2D and body != self):
		stuck_to_box = false
	elif(body is Player):
		stay_put = false


