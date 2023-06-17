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
