extends Node

@onready var enemy = $enemy
@onready var tile_map = $"../TileMap2" 
@onready var timer = $Timer # use a timer to get the enemies to shoot
@onready var scoreLabel = $"../text/score" # to update the player score
@onready var ufo_timer = $UFO_TIMER # spawn every 25 seconds
@onready var gameLoopTimer = $GameLoop



const MINTIME = 0
const MAXTIME = 3
const ENEMY = preload("res://scenes/enemy.tscn") # loading the 'enemy' scene
var score = 0

#enemy vars
var enemies = []
var shootingEnemies = []
var enemyProjectiles = [] # will be used to update the enemy projectiles
const PROJECTILESPEED = 300
var shooting = false

var direction = 1

var gameLoopSet = false

# ufo
const UFO_SPAWN_TIME: int = 25
const UFO = preload("res://scenes/ufo.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	# initializing the enemy nodes
	var xpos = -232
	var ypos = -192
	create_enemy_row(xpos, ypos, 1, 30)
	create_enemy_row(xpos, ypos + 50, 2, 20)
	create_enemy_row(xpos, ypos + 100, 2, 20)
	create_enemy_row(xpos, ypos + 150, 3, 10)
	create_enemy_row(xpos, ypos + 200, 3, 10)
	

	ufo_timer.start(UFO_SPAWN_TIME)
	
	
	


	
func create_enemy_row(startX: int, startY: int, enemyType: int, score: int) -> void:
	for i in 11:
		var enemy = ENEMY.instantiate() # creating a new instance of the scene
		enemy.position.x = startX
		enemy.position.y = startY
		enemy.type = enemyType
		enemy.score = score
		
		startX += 50
		add_child(enemy) # adding to the scene tree
		enemies.append(enemy)
		
		# if its a shooting type of enemy, i.e. enemy1 will add to the shooting array
		if enemyType == 1:
			shootingEnemies.append(enemy)
	
			
func _process(delta):
	
	# if not currently shooting, pick a random enemy to shoot
	if not shooting:
		activate_shooting()
		
	# gameloop
	if not gameLoopSet:
		gameLoopSet = true
		gameLoopTimer.start(1)
		
	
	
	
	var ufo = get_node_or_null('ufo')
	if ufo:
		ufo.move_ufo()
	
		
		
		
	
	
	
	
	# need to just format it slightly
	if score == 0:
		scoreLabel.text = "0000"
	elif score < 100:
		scoreLabel.text = "00" + str(score)
	elif score < 1000:
		scoreLabel.text = "0" + str(score)
	else:
		scoreLabel.text = str(score)
		
		
	
	# updating the enemy projectiles
	if not enemyProjectiles.is_empty():
		for projectile in enemyProjectiles:
			projectile.position.y += PROJECTILESPEED * delta
			
			
			
			
			var projectileCoord: Vector2i = tile_map.local_to_map(projectile.position) # gets the corresponding coord in the map
			var otherProjectileCoords: Vector2i = tile_map.local_to_map(Vector2i(projectile.position.x, projectile.position.y + 1))
			
		
			var mapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, projectileCoord) # says if there is something at those coords
			var otherMapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, otherProjectileCoords)
			# if the projectile is not at the bottom, delete the cell it collided with
			if mapCoord != Vector2i(-1, -1) or mapCoord != Vector2i(-1, -1):
				if not projectile.position.y >= 352:

					tile_map.erase_cell(0, projectileCoord)
					tile_map.erase_cell(0, otherProjectileCoords)
				projectile.queue_free()
				enemyProjectiles.erase(projectile)
			
		
		


func activate_shooting() -> void:
	var randomEnemy = get_random_enemy()
	
	var random_time = randi_range(MINTIME, MAXTIME)
	randomEnemy.shoot()
	timer.start(random_time)
	shooting = true
	
	
func get_random_enemy() -> Area2D:
	var randomIndex: int = randi_range(0, shootingEnemies.size()-1)
	var enemy = shootingEnemies[randomIndex]
	while not is_instance_valid(enemy):
		randomIndex = randi_range(0, enemies.size()-1)
		enemy = enemies[randomIndex]
	return enemy
		
	
func _on_timer_timeout():
	shooting = false

func _on_ufo_timer_timeout():
	
	# TODO make it so the ufo generate from a random side
	
	var directions = [1, -1]
	var left_or_right = randi_range(0, 1)
	var direction = directions[left_or_right]
	
	var ufo = UFO.instantiate()
	ufo.position.x = 256 * direction
	ufo.position.y = -256
	ufo.direction = direction
	ufo.name = "ufo"
	add_child(ufo)
	
	var tmp = get_child(3)


func _on_game_loop_timeout():
	var tmp = false
	var node
	# need to check if any of the enemies are colliding
	for enemy in enemies:
		if is_instance_valid(enemy):
			if enemy.colliding_left():
				direction = 1
				tmp = true
				node = enemy.get_node('rayCastLeft')
				node.enabled = false
				
			elif enemy.colliding_right():
				direction = -1 
				tmp = true
				node = enemy.get_node('rayCastRight')
				node.enabled = false

			
	
	if tmp:
		move_down()
	else:
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.position.x += 10 * direction
				var left = enemy.get_node('rayCastLeft')
				var right = enemy.get_node('rayCastRight')
				left.enabled = true
				right.enabled = true
		
	gameLoopSet = false

func move_down():
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.position.y += 10
