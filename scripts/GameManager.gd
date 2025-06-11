class_name GameManager

extends Node

@export var running: bool = false # false until we spawn all the enemies




@onready var tile_map = $"../TileMap" 

# LABELS
@onready var scoreLabel = $"../text/score" # to update the player score
@onready var ufo_score: Label = $"../text/ufo score"



# TIMERS
@onready var timer = $Timer # use a timer to get the enemies to shoot
@onready var ufoTimer = $ufoTimer # spawn every 25 seconds
@onready var gameLoopTimer = $GameLoop
@onready var deathTimer = $DeathTimer
@onready var ufo_score_timer: Timer = $"ufo score timer"
@onready var enemy_row_timer: Timer = $enemyRowTimer
@onready var start_timer: Timer = $startTimer # time to wait before setting running to true



@onready var explosion: AnimatedSprite2D = $explosion # explosion animation for the enemy


@onready var player = $"../player/player"


@onready var death_label = $"../text/death_label"

# SCENES
const ENEMY = preload("res://scenes/enemy.tscn") # loading the 'enemy' scene

# main game
var gameLoopSet = false
var score: int = 0

const deathTimoutDuration: int = 5 # the time the game freezes when the player dies
var deathTimerStarted: bool = false

#shooting
const PROJECTILESPEED: int = 950
const MINTIME: int = 0 # the mintime for an enemy to shoot
const MAXTIME: int = 3 # the maxtime for an enemy to shoot
var shooting_enemies: Array = []
var enemy_projectiles: Array = [] # will be used to update the enemy projectiles
var shooting = false # check if we are currently 'shooting'


# enemies
var enemies: Array = []
var direction: int = 1


# ufo
const UFO_SPAWN_TIME: int = 23
const UFO = preload("res://scenes/ufo.tscn")

@onready var character_functions: Node = $"../Character Functions"

# TODO speed up the game
# TODO change the player sprite
# TODO update death screen, make it gradual
# TODO change the score so that it is always getting from the global scope
# TODO update the high score on a gameover

# when the node enters the scene tree for the first time
func _ready() -> void:
	'''
	function that is called when the game manager enters the scene tree for the first time
	
	initializes all the enemies for the first time with their score and unique animations
	
	Plays the animation to spawn everything in
	
	'''

	const number_of_enemies_per_row: int = 11
	const spawn_interval: float = 0.05
	var time_to_wait: float = 0
	
	
	# TODO add the animation when initializing everything
	var xpos = -232
	var ypos = -192
	create_enemy_row(xpos, ypos, 1, 30, spawn_interval) # type 1 is a shooting enemy
	time_to_wait += number_of_enemies_per_row * spawn_interval 
	await get_tree().create_timer(time_to_wait).timeout
	
	create_enemy_row(xpos, ypos + 50, 2, 20, spawn_interval)
	time_to_wait += number_of_enemies_per_row * spawn_interval - 0.5
	await get_tree().create_timer(time_to_wait).timeout

	
	create_enemy_row(xpos, ypos + 100, 2, 20, spawn_interval)
	time_to_wait += number_of_enemies_per_row * spawn_interval -0.5
	await get_tree().create_timer(time_to_wait).timeout

	
	create_enemy_row(xpos, ypos + 150, 3, 10, spawn_interval)
	time_to_wait += number_of_enemies_per_row * spawn_interval -0.5
	await get_tree().create_timer(time_to_wait).timeout
	
	create_enemy_row(xpos, ypos + 200, 3, 10, spawn_interval)

	
	
	start_timer.start(time_to_wait + 1)  # on timeout will start the game
	ufoTimer.start(UFO_SPAWN_TIME) # starting the timer before spawning the ufo
	score = GlobleVars.score # loading the score back from prev rounds
	
	
func create_enemy_row(startX: int, startY: int, enemyType: int, score: int, spawn_interval: float) -> void:
	for i in 11: 
		var enemy: Area2D = ENEMY.instantiate() # creating a new instance of the scene
		
		# initializing the coords and type
		enemy.position.x = startX 
		enemy.position.y = startY
		enemy.type = enemyType
		enemy.score = score
		
		var animation_node = enemy.get_node("animation")
		
		
		add_child(enemy) # adding to the scene tree
		enemies.append(enemy) # add to the array of all enemies
		
		# if its a shooting type of enemy, i.e. enemy1 will add to the shooting array
		if enemyType == 1:
			shooting_enemies.append(enemy)
		
		startX += 50 # increment the x coord for the next enemy
		await get_tree().create_timer(spawn_interval).timeout
		
	

	
	
	
func _on_start_timer_timeout() -> void:
	for enemy in enemies:
		var animation_node = enemy.get_node("animation")
		animation_node.play()
	running = true
	
	
	
	
	

func format_score() -> void:
	if score == 0:
		scoreLabel.text = "0000"
	elif score < 100:
		scoreLabel.text = "00" + str(score)
	elif score < 1000:
		scoreLabel.text = "0" + str(score)
	else:
		scoreLabel.text = str(score)
	
	
# main game loop
func _process(delta):
	if player.lives == 0:
		running = false
		death_label.visible = true
		
		GlobleVars.isTitleScreen = false
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
		# TODO add gameover and swap back to title screen
		# TODO pause running again
		
	
	
	if enemies.is_empty():
		GlobleVars.score = score
		
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		
	if running:
		# if not currently shooting, pick a random enemy to shoot
		if not shooting:
			activate_shooting()
		
		# UFO
		var ufo = get_node_or_null('ufo') # check if there is a ufo in the scene tree
		if ufo:
			ufo.move_ufo()
		
		if not gameLoopSet and running:
			gameLoopSet = true
			gameLoopTimer.start(1) # this actually means that it is called each second, need to change the one shot
		
	
		# need to just format it slightly
		format_score()
		
		# updating the enemy projectiles
		update_enemy_projectiles(delta)
		
	# if the game is not running
	else:
		if not deathTimerStarted:
			deathTimerStarted = true
			deathTimer.start(deathTimoutDuration)
	
	

		
		
		
		


func activate_shooting() -> void:
	var random_enemy: Area2D = get_random_enemy()
	
	var random_time = randi_range(MINTIME, MAXTIME) 
	random_enemy.shoot()
	timer.start(random_time)
	shooting = true
	

#TODO FIX ENEMY SHOOTING
func get_random_enemy() -> Area2D:
	var random_index: int = randi_range(0, shooting_enemies.size()-1)
	var enemy: Area2D = shooting_enemies[random_index]
	while not is_instance_valid(enemy): # to ensure the enemy has not been previously freed
		random_index = randi_range(0, shooting_enemies.size()-1)
		enemy = shooting_enemies[random_index]
	return enemy
		
	
func _on_timer_timeout():
	shooting = false

func _on_ufo_timer_timeout():
	var directions = [1, -1]
	var left_or_right = randi_range(0, 1)
	var direction = directions[left_or_right]
	
	var ufo = UFO.instantiate()
	ufo.position.x = 256 * direction
	ufo.position.y = -242
	ufo.direction = direction
	ufo.name = "ufo"
	add_child(ufo)
	
	var tmp = get_child(3)


func _on_game_loop_timeout() -> void:
	
	gameLoopSet = false
	
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
				enemy.position.x += 10 * direction
				var left = enemy.get_node('rayCastLeft')
				var right = enemy.get_node('rayCastRight')
				left.enabled = true
				right.enabled = true
	

func move_down():
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.position.y += 10

func _on_death_timer_timeout():
	deathTimerStarted = false
	running = true


func update_enemy_projectiles(delta) -> void:
	
	# TODO reuse the code from the player
	if not enemy_projectiles.is_empty():
			for projectile in enemy_projectiles:
				
				var distance = Vector2(0, 1 * PROJECTILESPEED * delta) # calculate the distance in which we want to move the projecile
				var collision = projectile.move_and_collide(distance) # move the projectile this disance and check for collisions
				
				if collision:
					var collision_pos = Vector2i(collision.get_position()) + Vector2i(0, 1) # we want to check the coord one above the collision
					var object_coord: Vector2i = tile_map.local_to_map(collision_pos) # gets the corresponding coord in the map
					var map_coord: Vector2i = tile_map.get_cell_atlas_coords(0, object_coord) # will return either a valid or invalid tile
					
					
					tile_map.erase_cell(0, map_coord)
					#character_functions.remove_tile_explosion(collision_pos, tile_map) # remove multiple tiles
					# remove_child(projectile) # if there is a tile there remove the projectile
				
				
				
			
			 
					#projectile.queue_free()
					#enemy_projectiles.erase(projectile)
	#
	


func _on_ufo_score_timer_timeout() -> void:
	ufo_score.visible = false
