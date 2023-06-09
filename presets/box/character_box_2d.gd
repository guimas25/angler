extends CharacterBody2D
class_name Box2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var SPEED_PUSH = 250

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0, 50)

	move_and_slide()
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if collision.get_collider() is Box2D:
			print("collidion")
			collision.get_collider().slide(-collision.get_normal() * (SPEED_PUSH))

func slide(vector):
	velocity.x = vector.x