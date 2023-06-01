extends Area2D

func _on_body_entered(body):
	body.get_on_water()


func _on_body_exited(body):
	body.get_off_water()
