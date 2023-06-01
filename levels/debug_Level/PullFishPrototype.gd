extends CharacterBody2D

const CONST_RATE = 1.5
const SPEED = 700.0


func _ready():
	velocity.x = SPEED

func _process(delta):
	var pullDir = Vector2(velocity.x + position.x, velocity.y + position.y)
	$Sprite2D.look_at(pullDir)

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = lerp(velocity.x, SPEED, delta*CONST_RATE)
		velocity.y = lerp(velocity.y, 0.0, delta*CONST_RATE)
	if Input.is_action_pressed("ui_left"):
		velocity.x = lerp(velocity.x, -SPEED, delta*CONST_RATE)
		velocity.y = lerp(velocity.y, 0.0, delta*CONST_RATE)
	if Input.is_action_pressed("ui_up"):
		velocity.x = lerp(velocity.x, 0.0, delta*CONST_RATE)
		velocity.y = lerp(velocity.y, -SPEED, delta*CONST_RATE)
	if Input.is_action_pressed("ui_down"):
		velocity.x = lerp(velocity.x, 0.0, delta*CONST_RATE)
		velocity.y = lerp(velocity.y, SPEED, delta*CONST_RATE)
	
	velocity = velocity.normalized() * SPEED
	move_and_slide()


func _on_button_button_down():
	get_tree().change_scene_to_file("res://levels/debug_Level/debug_level_swing.tscn")
