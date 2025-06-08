extends Area2D

@onready var game_manager = get_parent()
@onready var ufo_timer = game_manager.get_child(1)
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var timer = $Timer
@onready var player = get_node("../../player/player")
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
	
	

	if not waiting:
		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			queue_free()
			ufo_timer.start(game_manager.UFO_SPAWN_TIME)
			
			
		position.x += move_distance * direction * -1
		timer.start(interval)
		waiting = true

func _on_timer_timeout():
	waiting = false




func _on_body_entered(projectile: CharacterBody2D):
	
	var score = generate_score()
	
	
	
	#TODO create a label when it dies
	ufo_score.visible = true
	ufo_score.position = position
	ufo_score.text = str(score)
	
	ufo_score_timer.start(1)
	
	
	
	
		
	queue_free() # removing the ufo
	projectile.queue_free() # removing from the scene tree
	player.projectile = null # removing from the array
	game_manager.score += score
