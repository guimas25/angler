extends Node2D

var direction = 0

func change_direction(left):
	if left:
		direction = -1
	else:
		direction = 1

func _on_area_2d_body_entered(body):
	if body is Player and not body.get_iframes():
		body.take_damage()
		body.velocity = Vector2(800 * direction, -500)
