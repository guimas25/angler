extends Sprite2D


@onready var player = get_tree().get_root().get_child(1).get_node("Player")

var follow_player = false

# Called when the node enters the scene tree for the first time.d
func _ready():
	print(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow_player:
		var target = Vector2(player.position.x, player.position.y - 12)
		self.position = position.slerp(target, 0.1)

func _on_area_2d_body_entered(body):
	$AudioStreamPlayer.play()
	body.add_item("Wacky Carp", "What a wacky fish guy.")
	$Area2D.set_collision_mask_value(1, false)
	follow_player = true
	$AnimationPlayer.play("picked_up")

func _on_animation_player_animation_finished(anim_name):
	queue_free()
