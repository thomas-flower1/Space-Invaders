extends Area2D

@onready var ray_cast_right = $rayCastRight
@onready var ray_cast_left = $rayCastLeft
@onready var game_manager = get_parent()
@onready var player = $"../../player/player"
@onready var animation = $animation
@onready var death_timer = $death_timer # keep the enemy alive for a second after the collision



const PROJECTILE = preload("res://scenes/projectile.tscn") # for creating the projectiles later

var type: int = 1 # the type of enemy it is
var score: int # the score value


# when the enemy is created, assign the animation with the type
func _ready():
	pass

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
	var death_delay: float = 0.1
	animation.play("explosion")
	projectile.queue_free()
	
	death_timer.start(death_delay) # start a timer before deleting the enemy
	
	
	
		
func _on_death_timer_timeout() -> void:
	'''
	Code for deleting the enemy once the "explosion" animation has played
	
	'''


	queue_free() # remove this enemy from the scene tree and delete
	game_manager.enemies.erase(self) # remove the enemy from the array
	game_manager.score += score # update the score
	
	# also need to check if the enemy is a shooting enemy, if so need to remove from the shooting array
	if type == 1:
		game_manager.shooting_enemies.erase(self)

func shoot():
	'''
	Code for creating a projectile from the enemy
	This projectile can be accesssed in the corrsponding array in the game manager
	'''
	
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = position.x
	projectile.position.y = position.y
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_layer_value(2, false)

	game_manager.add_child(projectile)

	game_manager.enemy_projectiles.append(projectile)
	



func colliding_left() -> bool:
	return ray_cast_left.is_colliding()

func colliding_right() -> bool:
	return ray_cast_right.is_colliding()
		
