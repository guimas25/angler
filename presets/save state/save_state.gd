extends Node

# Fish-Opedia seen fish array
# 0: Cool sardine
# 1: Wacky Tuna
# 2-7: to define AHAHAHHA
var seen_fish = [false,false,false,false,false,false,false,false,] 

# Inventory save
var inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
