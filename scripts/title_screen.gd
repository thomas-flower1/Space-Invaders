extends Node2D

@onready var play_label: Label = $play
@onready var space_invaders: Label = $"space invaders"
@onready var score_table: Label = $"score table"

# for the score label
@onready var mystery: Label = $scores/mystery
@onready var squid_points: Label = $"scores/squid points"
@onready var crab_points: Label = $"scores/crab points"
@onready var octo_points: Label = $"scores/octo points"


# images
@onready var ufo: Sprite2D = $sprites/UFO
@onready var squid: Sprite2D = $sprites/squid
@onready var crab: Sprite2D = $sprites/crab
@onready var octo: Sprite2D = $sprites/octo

# new game labels
@onready var push: Label = $newGame/Push
@onready var player_button: Label = $newGame/playerButton



const speed: float = 0.1
# called when enters the scene tree for the first time
func _ready():
	
	if GlobleVars.isTitleScreen:
		
		var delay: float = 0
		
		draw_text("PLAY", play_label) # for PLAY
		delay += time_to_wait("PLAY")
		await get_tree().create_timer(delay).timeout # setting a timeout before the next text

		draw_text("SPACE INVADERS", space_invaders)
		delay += time_to_wait("SPACE INVADERS")
		await get_tree().create_timer(delay).timeout # setting a timeout before the next text

		score_table.text = "*SCORE ADVANCE TABLE*" # just draw the whole text at once
		delay += time_to_wait("*SCORE ADVANCE TABLE*") - 4
		await get_tree().create_timer(delay).timeout
		
		# score table 
		ufo.visible = true
		draw_text("=? MYSTERY", mystery)
		delay += time_to_wait("=? MYSTERY") 
		await get_tree().create_timer(delay).timeout 
		
		squid.visible = true
		draw_text("=30  POINTS", squid_points)
		delay += time_to_wait("=30  POINTS") - 1
		await get_tree().create_timer(delay).timeout 
		
		
		crab.visible = true
		draw_text("=20  POINTS", crab_points)
		delay += time_to_wait("=20  POINTS") - 1
		await get_tree().create_timer(delay).timeout 
		
		octo.visible = true
		draw_text("=10  POINTS", octo_points)
	
	else: # if it is a new game screen
		push.visible = true
		player_button.visible = true
		
	
	



func time_to_wait(text: String, wait_time: float=speed) -> float:
	return len(text) * wait_time + wait_time
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("shoot"): # will only swap scenes if the space bar is pressed
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	



func draw_text(text: String, label: Label) -> void:
	'''
	Given text and the reference to a label, will draw the label character by character
	'''
	
	var text_arr: Array = text.split('')
	for c in text_arr:
		if !c == " ":
			await get_tree().create_timer(speed).timeout # wait one second
		label.text = label.text + c
	
		
	
