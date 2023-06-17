extends CharacterBody2D

const SPEED = 3000.0
const JUMP_VELOCITY = -400.0

var HP = 3

var is_moving_left = true

var attack_mode = false

var laser = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	if(HP <= 0):
		queue_free()
	detect_turn_around()
	detect_player()
	if velocity.x != 0:
		$AnimatedSprite2D.play("moving")
	elif laser:
		$AnimatedSprite2D.play("laser")
	elif attack_mode:
		$AnimatedSprite2D.play("attack")
	else:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if is_moving_left and not attack_mode:
		velocity.x = -SPEED * delta
	elif not is_moving_left and not attack_mode:
		velocity.x = SPEED * delta
	if attack_mode or laser:
		velocity.x = 0
	velocity.y += gravity * delta
	move_and_slide()

func detect_turn_around():
	if not $RayCastGround.is_colliding() and is_on_floor():
		is_moving_left = not is_moving_left
		scale.x = -scale.x
		#print("Turn around!")
	elif $RayCastWall.is_colliding() and not $RayCastWall.get_collider() is Player:
		is_moving_left = not is_moving_left
		scale.x = -scale.x
		#print("Turn around!")
		#print($RayCastWall.get_collider())
		
func detect_player():
	if $RayCastPlayer.is_colliding() and not attack_mode and not laser:
		attack_mode = true
	elif $RayCastPlayerBack.is_colliding() and not attack_mode and not laser:
		scale.x = -scale.x
		is_moving_left = not is_moving_left
		attack_mode = true
		#print("KILL!")

func get_hurt():
	HP = HP-1
	print("OUCH!")


func _on_animated_sprite_2d_animation_finished():
	if attack_mode:
		print("LASER TIME")
		laser = true
		attack_mode = false
	else:
		print("OFF")
		laser = false
