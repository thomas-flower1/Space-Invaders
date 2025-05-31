extends Node2D

@onready var play_label: Label = $play
@onready var space_invaders: Label = $"space invaders"
@onready var score_table: Label = $"score table"


# called when enters the scene tree for the first time
func _ready():
	var delay: float = 0
	
	draw_text("PLAY", play_label) # for PLAY
	delay += time_to_wait("PLAY")
	await get_tree().create_timer(delay).timeout # setting a timeout before the next text

	draw_text("SPACE INVADERS", space_invaders)
	delay += time_to_wait("SPACE INVADERS")
	await get_tree().create_timer(delay).timeout # setting a timeout before the next text

	score_table.text = "*SCORE ADVANCE TABLE*" # just draw the whole text at once



func time_to_wait(text: String, wait_time: float=0.3) -> float:
	return len(text) * wait_time + wait_time
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_anything_pressed(): # will change to the main scene
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	



func draw_text(text: String, label: Label) -> void:
	'''
	Given text and the reference to a label, will draw the label character by character
	'''
	
	var text_arr: Array = text.split('')
	for char in text_arr:
		await get_tree().create_timer(0.3).timeout # wait one second
		label.text = label.text + char
	
		
	


