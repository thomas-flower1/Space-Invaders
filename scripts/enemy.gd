extends Area2D

@onready var ray_cast_right = $rayCastRight
@onready var ray_cast_left = $rayCastLeft
@onready var game = get_parent()
@onready var player = $"../../player/player"
@onready var x_timer = $x_timer
@onready var animation = $AnimatedSprite2D
@onready var y_timer = $y_timer


const PROJECTILE = preload("res://scenes/projectile.tscn")

var type = 1 # the type of enemy it is
var score # the score value
var xTimerSet = false 
var yTimerSet = false



func _ready():
	if type == 1:
		animation.play("enemy1")
	elif type == 2:
		animation.play("enemy2")
	else:
		animation.play("enemy3")
		
		
		
func _on_body_entered(body):
	player.projectiles.remove_at(0)
	game.enemies.erase(body)
	
	body.queue_free()
	queue_free() # remove this enemy from the scene tree and delete
	game.score += score




	
	

func shoot():
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = position.x
	projectile.position.y = position.y
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_layer_value(2, false)

	game.add_child(projectile)

	game.enemyProjectiles.append(projectile)
	



func colliding_left() -> bool:
	return ray_cast_left.is_colliding()

func colliding_right() -> bool:
	return ray_cast_right.is_colliding()
		
