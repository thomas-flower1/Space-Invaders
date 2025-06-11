extends Area2D

@onready var game_manager: GameManager = get_parent()
@onready var ray_cast_right = $rayCastRight
@onready var ray_cast_left = $rayCastLeft
@onready var player = $"../../player/player"
@onready var animation = $animation
@onready var ray_cast_bottom: RayCast2D = $rayCastBottom


var type: int = 1 # the type of enemy it is
var score: int # the score value


# when the enemy is created, assign the animation with the type
func _ready():
	if type == 1:
		animation.play("enemy1")
	elif type == 2:
		animation.play("enemy2")
	else:
		animation.play("enemy3")
	
	animation.stop() # pause the animation until the game starts
	

func _on_body_entered(projectile: CharacterBody2D) -> void:
	'''
	When a player projectile enters the enemy body
	Play an animation, delete the projecile, wait, then delete the enemy
	
	'''
	game_manager.enemies.erase(self)
	queue_free()
	
	
	#var death_delay: float = 0.1
	#animation.play("explosion")
	#projectile.queue_free()
	#
	#death_timer.start(death_delay) # start a timer before deleting the enemy
	
	
	
		
func _on_death_timer_timeout() -> void:
	'''
	Code for deleting the enemy once the "explosion" animation has played
	
	'''


	queue_free() # remove this enemy from the scene tree and delete
	game_manager.enemies.erase(self) # remove the enemy from the array
	game_manager.score += score # update the score



func colliding_left() -> bool:
	return ray_cast_left.is_colliding()

func colliding_right() -> bool:
	return ray_cast_right.is_colliding()
		
func colliding_bottom() -> bool:
	return ray_cast_bottom.is_colliding()
