extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")
	$Player/Camera2D.limit_bottom = 460
	$Player/Camera2D.limit_top = -1859
	$Player/Camera2D.limit_left = 37
	$Player/Camera2D.limit_right = 1094


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimatedSprite2D/time.text = "Finish Time: " + str(snapped(SaveState.current_time, 0.01)) + "s"
	if SaveState.minigame_failure + SaveState.minigame_success != 0:
		$AnimatedSprite2D/minigame.text = "Minigame rate: " + str(snapped((SaveState.minigame_success/float(SaveState.minigame_failure + SaveState.minigame_success)) * 100.0, 0.01)) + "%"
	else:
		$AnimatedSprite2D/minigame.text = "Minigame Success rate: none"
	$AnimatedSprite2D/n_deaths.text = "nº of deaths: " + str(SaveState.n_deaths)
	var i = 0
	for j in SaveState.seen_fish:
		if j:
			i = i + 1
	$AnimatedSprite2D/fishopedia.text = "Fishopedia: " + str(i/8.0 * 100.0) + "%"


func _on_area_2d_body_entered(body):
	SaveState.stop_the_timer()
