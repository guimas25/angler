extends Node

# Fish-Opedia seen fish array
# 0: Cool sardine
# 1: Wacky Tuna
# 2-7: to define AHAHAHHA
var seen_fish = [false,false,false,false,false,false,false,false,] 

var start_timer = false

var current_time = 0

var minigame_success = 0

var minigame_failure = 0

var n_deaths = 0

# Inventory save
var inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start_timer:
		current_time = current_time + delta

# Check if fish already on fishopedia
func check_fihsopedia(name):
	match name:
		"Cool Sardine":
			seen_fish[0] = true
		"Wacky Carp":
			seen_fish[1] = true
		"Shy Jellyfish":
			seen_fish[2] = true
		"Lemon Sardine":
			seen_fish[3] = true
		"Red Salmon":
			seen_fish[4] = true
		"Shrimp":
			seen_fish[5] = true
		"Silver Fish":
			seen_fish[6] = true
		"Yellowfin Tuna":
			seen_fish[7] = true

func start_the_timer():
	start_timer = true
	
func stop_the_timer():
	start_timer = false
