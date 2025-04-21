extends Area2D

@onready var ray_cast_right = $RayCast2D 
@onready var ray_cast_left = $RayCast2D2

@onready var game = get_parent()
@onready var player = $"../../player/player"

var type = 1
var score


@onready var timer = $Timer
var timerSet = false

const PROJECTILE = preload("res://scenes/projectile.tscn")
var direction = 1
@onready var animation = $AnimatedSprite2D


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


# on each frame
func _process(delta):
	if ray_cast_right.is_colliding():
		for enemy in game.enemies:
			if is_instance_valid(enemy):
				enemy.direction = -1
				#enemy.position.y += 10
				
		
	
	if ray_cast_left.is_colliding():
		for enemy in game.enemies:
			if is_instance_valid(enemy):
				enemy.direction = 1
				#enemy.position.y += 10
				
				
	
	if not timerSet:
		timerSet = true
		timer.start(1)
		

func _on_timer_timeout():
	position.x += 10 * direction
	timerSet = false
	
	

func shoot():
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = position.x
	projectile.position.y = position.y
	projectile.set_collision_layer_value(3, true)
	projectile.set_collision_layer_value(2, false)

	game.add_child(projectile)

	game.enemyProjectiles.append(projectile)
	








	
	



