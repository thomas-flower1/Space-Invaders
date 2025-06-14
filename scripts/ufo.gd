extends Area2D

@onready var game_manager = %GameManager
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight

@onready var interval_timer: Timer = $interval

@onready var score_label: Label = $"score label"
@onready var ufo_score: Label = $"../../text/ufoScore" 

@onready var score_display_timer: Timer = $scoreDisplayTimer



const interval: float = 0.3
const move_distance: int = 20
const score_display_duration: float = 1


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
	GlobleVars.score += score
	projectile.position = game_manager.hidden_coord
	
	ufo_score.visible = true
	ufo_score.position = position
	ufo_score.text = str(score)
	
	position = game_manager.ufo_hidden_coord # hiding the ufo again
	score_display_timer.start(2)


func _on_score_display_timer_timeout() -> void:
	ufo_score.visible = false
