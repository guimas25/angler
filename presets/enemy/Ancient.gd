extends CharacterBody2D

const SPEED = 3000.0
const JUMP_VELOCITY = -400.0

var hp = 3

var is_moving_left = true

var attack_mode = false

var laser = false

var cooldown = false

var took_damage = false

var laser_resource = preload("res://presets/enemy/laser.tscn")

var laser_instance

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	detect_turn_around()
	detect_player()
	if velocity.x != 0 and not laser and not attack_mode:
		$AnimatedSprite2D.play("moving")
	elif laser:
		$AnimatedSprite2D.play("laser")
	elif attack_mode:
		$AnimatedSprite2D.play("attack")
	else:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if is_moving_left and not attack_mode and not took_damage and not laser:
		velocity.x = -SPEED * delta
	elif not is_moving_left and not attack_mode and not took_damage and not laser:
		velocity.x = SPEED * delta
	
	elif (attack_mode or laser) and not took_damage:
		velocity.x = 0
	if is_moving_left and laser:
		laser_instance.position.x = position.x - 48
		laser_instance.position.y = self.position.y - 4
	elif not is_moving_left and laser:
		laser_instance.position.x = position.x + 48
		laser_instance.position.y = self.position.y - 4
	velocity.y += gravity * delta
	move_and_slide()

func detect_turn_around():
	if not $RayCastGround.is_colliding() and is_on_floor():
		is_moving_left = not is_moving_left
		scale.x = -scale.x
	elif $RayCastWall.is_colliding() and not $RayCastWall.get_collider() is Player:
		is_moving_left = not is_moving_left
		scale.x = -scale.x
		
func detect_player():
	if $RayCastPlayer.is_colliding() and not attack_mode and not laser and not cooldown:
		attack_mode = true
	elif $RayCastPlayerBack.is_colliding() and not attack_mode and not laser:
		scale.x = -scale.x
		is_moving_left = not is_moving_left
		if not cooldown:
			attack_mode = true

func get_hurt(pos):
	took_damage = true
	if sign(position.x - pos.x) < 0:
		self.velocity = Vector2(-100, -150)
	elif sign(position.x - pos.x) > 0:
		self.velocity = Vector2(100, -150)
	hp = hp - 1
	if hp <= 0:
		$AnimatedSprite2D/AnimationPlayer.play("death")
	else:
		$AnimatedSprite2D/AnimationPlayer.play("damage")

func _on_animated_sprite_2d_animation_finished():
	if attack_mode:
		laser = true
		laser_instance = laser_resource.instantiate()
		laser_instance.change_direction(is_moving_left)
		if is_moving_left:
			laser_instance.position.x = self.position.x - 48
		else:
			laser_instance.scale.x = -scale.x
			laser_instance.position.x = self.position.x + 48
		laser_instance.position.y = self.position.y - 4
		get_tree().get_root().add_child(laser_instance)
		attack_mode = false
		laser_instance.timer_start()
	else:
		laser = false
		cooldown = true
		$Timer.start()

func _on_timer_timeout():
	cooldown = false

func _on_animation_player_animation_finished(anim_name):
	if took_damage:
		took_damage = false
	if hp <= 0:
		if laser:
			laser_instance.queue_free()
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Player and not body.get_iframes():
		body.take_damage()
		if sign(position.x - body.position.x) < 0:
			body.velocity = Vector2(800, -500)
		elif sign(position.x - body.position.x) > 0:
			body.velocity = Vector2(-800, -500)
