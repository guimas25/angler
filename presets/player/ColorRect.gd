extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_stats"):
		visible = not visible
		if visible:
			SaveState.stop_the_timer()
		else:
			SaveState.start_the_timer()
		$time.text = "Finish Time: " + str(snapped(SaveState.current_time, 0.01)) + "s"
		if SaveState.minigame_failure + SaveState.minigame_success != 0:
			$minigame.text = "Minigame rate: " + str(snapped((SaveState.minigame_success/float(SaveState.minigame_failure + SaveState.minigame_success)) * 100.0, 0.01)) + "%"
		else:
			$minigame.text = "Minigame Success rate: none"
		$n_deaths.text = "nº of deaths: " + str(SaveState.n_deaths)
		var i = 0
		for j in SaveState.seen_fish:
			if j:
				i = i + 1
		$fishopedia.text = "Fishopedia: " + str(i/8.0 * 100.0) + "%"
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
