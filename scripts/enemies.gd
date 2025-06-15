extends Node


@onready var projectiles: Node = $"../projectiles"

const ENEMY = preload("res://scenes/enemy.tscn") # loading the 'enemy' scene 

var enemies: Array = []
var direction: int = 1
var invader_distance: int = 10

func create_enemy_row(start_x: int, start_y: int, enemy_type: int, score: int, spawn_interval: float, number_per_row: int=11) -> void:
	
	for i in number_per_row: 
		var enemy: Area2D = ENEMY.instantiate() # creating a new instance of the scene
		
		# initializing the coords and type
		enemy.position.x = start_x
		enemy.position.y = start_y
		enemy.type = enemy_type
		enemy.score = score
		
		add_child(enemy) # adding to the scene tree
		enemies.append(enemy) # add to the array of all enemies
		
		start_x += 50 # increment the x coord for the next enemy
		await get_tree().create_timer(spawn_interval).timeout 
		


func activate_shooting() -> void:
	var random_enemy: Area2D = get_random_enemy()
	
	# need to get valid projectile
	var projectile = projectiles.get_random_projectile()
	if projectile:
		projectile.position = random_enemy.position
	

func get_random_enemy() -> Area2D:
	var random_index: int = randi_range(0, enemies.size()-1)
	var enemy: Area2D = enemies[random_index]
	while !is_instance_valid(enemy) or enemy.colliding_bottom(): # getting an enemy with nothing underneath
		random_index = randi_range(0, enemies.size()-1)
		enemy = enemies[random_index]
	return enemy
	


func _on_game_loop_timer_timeout() -> void:
	var touchingWall: bool = false
	var node = null
	
	# need to check if any of the enemies are colliding
	for enemy in enemies:
		if is_instance_valid(enemy):
			if enemy.colliding_left():
				direction = 1
				touchingWall = true
				node = enemy.get_node('rayCastLeft')
				node.enabled = false
				
			elif enemy.colliding_right():
				direction = -1 
				touchingWall = true
				node = enemy.get_node('rayCastRight')
				node.enabled = false

	if touchingWall:
		move_down()
	else:
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.position.x += invader_distance * direction
				var left = enemy.get_node('rayCastLeft')
				var right = enemy.get_node('rayCastRight')
				left.enabled = true
				right.enabled = true


func move_down():
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.position.y += 10
 
func reached_bottom() -> bool:
	for enemy in enemies:
		if enemy.position.y >= 192:
			return true
	return false
