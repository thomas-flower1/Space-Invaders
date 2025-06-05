extends Area2D

@onready var game_manager = get_parent()
@onready var ufo_timer = game_manager.get_child(1)
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var timer = $Timer
@onready var player = get_node("../../player/player")

const interval: float = 0.3
const move_distance: int = 20
var waiting = false
var score
var direction = 1



# TODO fix the ufo
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
	queue_free() # removing the ufo
	projectile.queue_free() # removing from the scene tree
	player.projectile = null # removing from the array
	game_manager.score += generate_score()
