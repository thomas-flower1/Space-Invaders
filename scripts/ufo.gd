extends Area2D

@onready var game_manager = %GameManager
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight

@onready var interval_timer: Timer = $interval

@onready var score_label: Label = $"score label"
@onready var display_score: Timer = $"display score"
@onready var ufo_score: Label = $"../../text/ufo score" 

@onready var ufo_score_timer: Timer = $"../ufo score timer"



const interval: float = 0.3
const move_distance: int = 20

var waiting: bool = false

var direction: int = 1


func generate_score() -> int:
	var SCORES = [100, 150, 200, 250, 300]
	var index = randi_range(0, SCORES.size()-1)
	return SCORES[index]
	


func move_ufo() -> void:

	if interval_timer.is_stopped(): # if the timer is not running
		
		interval_timer.start(interval)
		position.x += move_distance * direction * -1
		

		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			visible = false
			position = game_manager.hidden_coord
	
	
		
		
		





func _on_body_entered(projectile: CharacterBody2D):
	
	var score = generate_score()
	
	# creating and displaying the score on death
	ufo_score.visible = true
	ufo_score.position = position
	ufo_score.text = str(score)
	
	#ufo_score_timer.start(1)
	
	# TODO add explosion on death
	position = game_manager.hidden_coord

	
	
	
		#
	#queue_free() # removing the ufo
	#projectile.queue_free() # removing from the scene tree
	#player.projectile = null # removing from the array
	#game_manager.score += score
