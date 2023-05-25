extends Node2D




func _on_area_2d_body_entered(body):
	$StaticBody2D.set_collision_layer_value(1, false)
	$StaticBody2D.set_collision_mask_value(1, false)


func _on_area_2d_body_exited(body):
	pass
	#$Player.velocity.y = -1000


func _on_area_2d_2_body_entered(body):
	$Player.velocity.y = -500
	$StaticBody2D.set_collision_layer_value(1, true)
	$StaticBody2D.set_collision_mask_value(1, true)


func _on_area_2d_3_area_entered(area):
	$StaticBody2D2.set_collision_layer_value(1, true)
	$StaticBody2D2.set_collision_mask_value(1, true)
	print("A")


func _on_area_2d_3_area_exited(area):
	$StaticBody2D3.set_collision_layer_value(1, false)
	$StaticBody2D3.set_collision_mask_value(1, false)
	print("B")
