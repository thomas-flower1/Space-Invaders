extends Area2D

@onready var game_manager = get_parent()

@onready var ufo_timer = game_manager.get_child(1)
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var timer = $Timer

const interval: float = 0.3
const move_distance: int = 20
var waiting = false




func move_ufo() -> void:
	print(ufo_timer)
	if not waiting:
		if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
			queue_free()
			ufo_timer.start(game_manager.UFO_SPAWN_TIME)
			
			
		position.x += move_distance
		timer.start(interval)
		waiting = true

func _on_timer_timeout():
	waiting = false
