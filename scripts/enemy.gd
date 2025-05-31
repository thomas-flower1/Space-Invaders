extends Area2D

@onready var ray_cast_right = $rayCastRight
@onready var ray_cast_left = $rayCastLeft
@onready var game_manager = get_parent()

@onready var player = $"../../player/player"
@onready var x_timer = $x_timer
@onready var animation = $AnimatedSprite2D
@onready var y_timer = $y_timer


const PROJECTILE = preload("res://scenes/projectile.tscn")

var type: int = 1 # the type of enemy it is
var score: int # the score value
var xTimerSet: bool = false 
var yTimerSet: bool = false


# when the enemy is created, assign the animation with the type
func _ready():
	if type == 1:
		animation.play("enemy1")
	elif type == 2:
		animation.play("enemy2")
	else:
		animation.play("enemy3")
	

func _on_body_entered(body) -> void:
	'''
	When a player projectile enters the enemy body
	Remove the enemy and projecitle, update the score
	
	'''
	player.projectiles.remove_at(0) # remove the projectile from the projecile array
	body.queue_free() # remove the projectile from the scene tree

	queue_free() # remove this enemy from the scene tree and delete
	game_manager.score += score # update the score
	
	# also need to check if the enemy is a shooting enemy, if so need to remove from the shooting array
	if type == 1:
		game_manager.shooting_enemies.erase(self)
		



func shoot():
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = position.x
	projectile.position.y = position.y
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_layer_value(2, false)

	game_manager.add_child(projectile)

	game_manager.enemyProjectiles.append(projectile)
	



func colliding_left() -> bool:
	return ray_cast_left.is_colliding()

func colliding_right() -> bool:
	return ray_cast_right.is_colliding()
		
