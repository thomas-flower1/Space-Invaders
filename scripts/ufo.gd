extends Area2D

@onready var game_manager = %GameManager
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight

@onready var interval_timer: Timer = $interval


@onready var ufo_score: Label = $ufoScore
@onready var ufo_sprite: Sprite2D = $ufo
@onready var score_display_timer: Timer = $scoreDisplayTimer
@onready var collisions: CollisionShape2D = $collisions



const interval: float = 0.3
const move_distance: int = 20
const score_display_duration: float = 1


var direction: int = 1
var ufo_on_screen: bool = false



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
			position = game_manager.ufo_hidden_coord
			ufo_on_screen = false


func _on_body_entered(projectile: CharacterBody2D):

		# if collides with player projectile
	var score = generate_score()
	GlobleVars.score += score
	ufo_score.text = str(score)
	ufo_score.visible = true
	score_display_timer.start(2)
		
	ufo_sprite.visible = false
	projectile.position = game_manager.hidden_coord
	collisions.disabled = true
	ufo_on_screen = false
	
	
	
	
	
	
	


func _on_score_display_timer_timeout() -> void:
	position = game_manager.ufo_hidden_coord # hiding the ufo again 
	ufo_score.visible = false
	collisions.disabled = false
	ufo_sprite.visible = true
