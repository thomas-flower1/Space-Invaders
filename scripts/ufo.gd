extends Area2D

@onready var game_manager = %GameManager
@onready var ufo_score: Label = $ufoScore
@onready var ufo_sprite: Sprite2D = $ufoSprite
@onready var collisions: CollisionShape2D = $collisions

@onready var ray_cast_right: RayCast2D = $rayCastRight
@onready var ray_cast_left: RayCast2D = $rayCastLeft

@onready var score_display_timer: Timer = $timer/scoreDisplayTimer
@onready var interval_timer: Timer = $timer/intervalTimer
@onready var spawn_timer: Timer = $timer/spawnTimer



const interval: float = 0.5 # the ufo moves every 0.5 seconds
const move_distance: int = 20
const score_display_duration: int = 1 # how long to display the score after shot

var direction: int

func move_ufo() -> void:
	interval_timer.start(interval)
	position.x -= move_distance * direction
	
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		ufo_sprite.visible = false
		position = game_manager.ufo_hidden_coord



func _on_body_entered(projectile: CharacterBody2D):
		
	if not collisions.disabled:
		collisions.disabled = true
		var score = generate_score()

		GlobleVars.score += score
		ufo_score.text = str(score)
		ufo_score.visible = true
		score_display_timer.start(score_display_duration)
				
		ufo_sprite.visible = false
		projectile.position = game_manager.hidden_coord


		# need to resart the spwan timer
		start_ufo_spawn_timer()


func generate_score() -> int:
	var SCORES = [100, 150, 200, 250, 300]
	return SCORES.pick_random()



func _on_score_display_timer_timeout() -> void:
	position = game_manager.ufo_hidden_coord # hiding the ufo again 
	ufo_score.visible = false


	
# spawning ufo
func start_ufo_spawn_timer():
	const time_to_spawn: int = 23
	spawn_timer.start(time_to_spawn)
	

func _on_spawn_timer_timeout() -> void:
	var directions = [1, -1].pick_random()
	position.x = 256 * directions 
	position.y = -242
	direction = directions
	
	ufo_sprite.visible = true
	collisions.disabled = false 
