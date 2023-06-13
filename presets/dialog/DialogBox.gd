extends ColorRect
 
@export var dialogPath = ""
@export var textSpeed = 0.05
 
var dialog
 
var phraseNum = 0
var finished = false
 
func _ready():
	$Indicator/AnimationPlayer.play("indicator_animation")
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()
 
func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("melee_action"):
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)
 
func getDialog() -> Array:
	assert(FileAccess.file_exists(dialogPath), "File path does not exist")
	var f = FileAccess.open(dialogPath, FileAccess.READ)

	var output = JSON.parse_string(f.get_as_text())
	print(output)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
 
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		queue_free()
		return
	
	finished = false
	
	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	$Text.visible_characters = 0
	
	var img = dialog[phraseNum]["Name"] + "/" + dialog[phraseNum]["Emotion"] + ".png"
	img = "res://assets/dialog/" + img
	print(img)
	if FileAccess.file_exists(img):
		$Portrait.texture = load(img)
	else: $Portrait.texture = null
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		await $Timer.timeout
	
	finished = true
	phraseNum += 1
	return
