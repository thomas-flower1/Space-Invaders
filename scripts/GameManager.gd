class_name GameManager

extends Node


# LABELS

@onready var ufo_score: Label = $"../text/ufo score"



# TIMERS
@onready var ufo_timer = $ufoTimer # spawn every 25 seconds
@onready var gameLoopTimer = $GameLoop
@onready var deathTimer = $DeathTimer
@onready var ufo_score_timer: Timer = $"ufo score timer"
@onready var enemy_row_timer: Timer = $enemyRowTimer



@onready var explosion: AnimatedSprite2D = $explosion # explosion animation for the enemy


@onready var player = $"../player/player"



# SCENES

# main game
var gameLoopSet = false

const deathTimoutDuration: int = 5 # the time the game freezes when the player dies
var deathTimerStarted: bool = false

#shooting

var shooting = false # check if we are currently 'shooting'



# ufo
const UFO_SPAWN_TIME: int = 23



###################################################################
@onready var shield_collisions: Node = %ShieldCollisions
@onready var start_timer: Timer = $startTimer # time to wait before setting running to true
@onready var shooting_interval = $shootingInterval # use a timer to get the enemies to shoot
@onready var tile_map: TileMap = $"../world/TileMap"



@export var running: bool = false # false until we spawn all the enemies

const PROJECTILE = preload("res://scenes/projectile.tscn")
const ENEMY = preload("res://scenes/enemy.tscn") # loading the 'enemy' scene 

var player_projectiles: Array = []
var enemy_projectiles: Array = [] 
var enemies: Array = []
const MINTIME: float = 0.6# the mintime for an enemy to shoot
const MAXTIME: float = 0.9 # the maxtime for an enemy to shoot
const PROJECTILESPEED: int = 400


var direction = 1 # for the movement, whether moving left or right
var hidden_coord: Vector2i = Vector2i(1000, 1000)


@onready var score_label = $"../text/score" # to update the player score
@onready var lives_label: Label = $"../text/livesLabel"
@onready var game_over_label: Label = $"../text/gameOverLabel"
@onready var high_score: Label = $"../text/highScore"


@onready var text: Node = $"../text" # for the gradual draawing function
@onready var ufo: Area2D = $"../ufo/UFO"

@onready var life_1: Sprite2D = $"../images/life1"
@onready var life_2: Sprite2D = $"../images/life2"

@onready var player_projectile: CharacterBody2D = $"../player/projectile"



# TODO speed up the game
# TODO change the score so that it is always getting from the global scope

# when the node enters the scene tree for the first time
func _ready() -> void:
	'''
	function that is called when the game manager enters the scene tree for the first time
	
	initializes all the enemies for the first time with their score and unique animations
	
	Plays the animation to spawn everything in
	
	'''
	
	score_label.text = text.format_score(GlobleVars.score)
	high_score.text  = text.format_score(GlobleVars.high_score)
	GlobleVars.is_title_screen = false # will never go back to the title screen
	player_projectiles.append(player_projectile)
	
	
	
	const number_of_enemies_per_row: int = 11
	const spawn_interval: float = 0.05
	var time_to_wait: float = 0
	
	
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
	ufo_timer.start(UFO_SPAWN_TIME) # starting the timer before spawning the ufo
	ufo.position = hidden_coord
	

	
	
	var number_of_enemy_projectiles: int = 12
	for i in range(number_of_enemy_projectiles):
		var enemy_projectile = PROJECTILE.instantiate();
		enemy_projectile.id = i % 3 # the 3 if how many animations I have
		enemy_projectile.position = Vector2i(1000, 1000) # move this into a global varaible
		add_sibling(enemy_projectile)
		enemy_projectiles.append(enemy_projectile)
	
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
		
	
func _on_start_timer_timeout() -> void:
	for enemy in enemies:
		var animation_node = enemy.get_node("animation")
		animation_node.play()
	running = true
	
	
func _physics_process(delta: float) -> void:
	
	# for the player projeciles
	if !player_projectiles.is_empty():
		for projectile in player_projectiles:
			if Vector2i(projectile.position) != hidden_coord:
				shield_collisions.handle_shield_collision(projectile, tile_map, delta, player_projectiles, -1)
	
	# do the same for the enemy projectiles
	
	if !enemy_projectiles.is_empty() and running:
		for projectile in enemy_projectiles:
			if Vector2i(projectile.position) != hidden_coord:
				shield_collisions.handle_shield_collision(projectile, tile_map, delta, enemy_projectiles, 1)
			
	
# main game loop
func _process(delta):
	
	# if death
	if GlobleVars.lives == 0:
		
		running = false
		if not game_over_label.visible:
			text.draw_text("GAME OVER", game_over_label)
		game_over_label.visible = true
		
		player_projectiles.clear()
		enemy_projectiles.clear()
		
		# check and update the high score
		if GlobleVars.score > GlobleVars.high_score:
			GlobleVars.high_score = GlobleVars.score
		
	
		
		
		if Input.is_action_just_pressed("ui_accept"):
			GlobleVars.lives = 3 # reset lives, 
			game_over_label.visible = false
			GlobleVars.score = 0 # reset the score
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
			
	

	
	
	elif enemies.is_empty():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		
	if running:
		if shooting_interval.is_stopped():
			shooting_interval.start(randf_range(MINTIME, MAXTIME))
		

	
		
		# TODO the lives images
		if GlobleVars.lives == 2:
			life_1.visible = false
		if GlobleVars.lives == 1:
			life_2.visible = false
	
		
		
		
	
		#ufo 
		if ufo.visible:
			ufo.move_ufo()
		
		if not gameLoopSet:
			gameLoopSet = true
			gameLoopTimer.start(1) # this actually means that it is called each second, need to change the one shot
		
	
		# SCORE
		score_label.text = text.format_score(GlobleVars.score)
		lives_label.text = str(GlobleVars.lives)
		
		
		
		
	# if the game is not running
	else:
		if not deathTimerStarted:
			deathTimerStarted = true
			deathTimer.start(deathTimoutDuration)
	
	


func activate_shooting() -> void:
	'''
	Picks a random enemy with no enemies underneath
	Takes a projectile and adds to the projecitle array
	Starts an interval between the next shot
	
	'''
	var random_enemy: Area2D = get_random_enemy()
	var random_time = randi_range(MINTIME, MAXTIME) 
	
	# need to get valid projectile
	var projectile = get_random_projectile()
	projectile.position = random_enemy.position
	
	#for projectile in get_parent().get_children():
		#if projectile is CharacterBody2D and not enemy_projectiles.has(projectile):
			#
			#projectile.position = Vector2i(random_enemy.position)
			#enemy_projectiles.append(projectile)
	
	
	

func get_random_enemy() -> Area2D:
	var random_index: int = randi_range(0, enemies.size()-1)
	var enemy: Area2D = enemies[random_index]
	while !is_instance_valid(enemy) or enemy.colliding_bottom(): # getting an enemy with nothing underneath
		random_index = randi_range(0, enemies.size()-1)
		enemy = enemies[random_index]
	return enemy
		
	


func get_random_projectile():
	enemy_projectiles.shuffle()
	for projectile in enemy_projectiles:
		if Vector2i(projectile.position) == hidden_coord:
			return projectile
		












func _on_ufo_timer_timeout():
	var directions = [1, -1]
	var left_or_right = randi_range(0, 1)
	var direction = directions[left_or_right]
	
	
	ufo.visible = true
	ufo.position.x = 256 * direction
	ufo.position.y = -242
	ufo.direction = direction
	
	


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


	


func _on_ufo_score_timer_timeout() -> void:
	ufo_score.visible = false


func _on_shooting_interval_timeout() -> void:     
	activate_shooting()
