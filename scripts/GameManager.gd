class_name GameManager

extends Node


###################################################################
# Nodes
@onready var shield_collisions: Node = %shieldCollisions
@onready var projectiles: Node = $"../projectiles"
@onready var enemies: Node = $"../enemies"

# Timers
@onready var shooting_timer: Timer = $"../timers/shootingTimer"
@onready var game_loop_timer: Timer = $"../timers/gameLoopTimer"
@onready var start_timer: Timer = $"../timers/startTimer"

@onready var tile_map: TileMap = $"../world/TileMap"

@export var running: bool = false # false until we spawn all the enemies


var player_projectiles: Array = []
@onready var player: CharacterBody2D = $"../player/player"


const MINTIME: float = 0.6# the mintime for an enemy to shoot  remove
const MAXTIME: float = 0.9 # the maxtime for an enemy to shoot remove

const PROJECTILESPEED: int = 400
const PLAYERPROJECILESPEED: int = 800


var hidden_coord: Vector2i = Vector2i(1000, 1000)
var ufo_hidden_coord: Vector2i = Vector2i(-1000, -1000)


# labels
@onready var score_label = $"../text/score" # to update the player score
@onready var lives_label: Label = $"../text/livesLabel"
@onready var game_over_label: Label = $"../text/gameOverLabel"
@onready var high_score: Label = $"../text/highScore"


@onready var text: Node = $"../text" # for the gradual draawing function
@onready var ufo: Area2D = $"../ufo/UFO"

@onready var life_1: Sprite2D = $"../images/life1"
@onready var life_2: Sprite2D = $"../images/life2"

@onready var player_projectile: CharacterBody2D = $"../player/projectile"

# when the node enters the scene tree for the first time
func _ready() -> void:
	
	

	GlobleVars.is_title_screen = false # will never go back to the title screen
	
	score_label.text = text.format_score(GlobleVars.score)
	high_score.text  = text.format_score(GlobleVars.high_score)

	player_projectiles.append(player_projectile)
	
	const number_of_enemies_per_row: int = 11
	const spawn_interval: float = 0.05
	var time_to_wait: float = 0 # used to calculate the time between rows
	
	var xpos = -232
	var ypos = -192
	
	enemies.create_enemy_row(xpos, ypos, 1, 30, spawn_interval) 
	time_to_wait += number_of_enemies_per_row * spawn_interval 
	await get_tree().create_timer(time_to_wait).timeout
	
	#enemies.create_enemy_row(xpos, ypos + 50, 2, 20, spawn_interval)
	#time_to_wait += number_of_enemies_per_row * spawn_interval - 0.5
	#await get_tree().create_timer(time_to_wait).timeout
#
	#
	#enemies.create_enemy_row(xpos, ypos + 100, 2, 20, spawn_interval)
	#time_to_wait += number_of_enemies_per_row * spawn_interval -0.5
	#await get_tree().create_timer(time_to_wait).timeout
#
	#
	#enemies.create_enemy_row(xpos, ypos + 150, 3, 10, spawn_interval)
	#time_to_wait += number_of_enemies_per_row * spawn_interval -0.5
	#await get_tree().create_timer(time_to_wait).timeout
	#
	#enemies.create_enemy_row(xpos, ypos + 200, 3, 10, spawn_interval)

	
	start_timer.start(time_to_wait + 1)  # on timeout will start the game
	ufo.start_ufo_spawn_timer() # spawnt time for the ufo
	
	projectiles.initialize_projectiles() # creates projectiles, adds them to the scene tree and the enemy projeciles array
	
	shooting_timer.start(randf_range(MINTIME, MAXTIME))
	game_loop_timer.start(1) 

		
	
func _on_start_timer_timeout() -> void:
	for enemy in enemies.enemies:
		var animation_node = enemy.get_node("animation")
		animation_node.play()
	running = true
	
	
func _physics_process(delta: float) -> void:
	
	# for the player projeciles
	if !player_projectiles.is_empty():
		for projectile in player_projectiles:
			if Vector2i(projectile.position) != hidden_coord:
				shield_collisions.handle_shield_collision(projectile, tile_map, delta, player_projectiles, -1, PLAYERPROJECILESPEED)
	
	# do the same for the enemy projectiles
	if !projectiles.enemy_projectiles.is_empty() and running:
		for projectile in projectiles.enemy_projectiles:
			if Vector2i(projectile.position) != hidden_coord:
				shield_collisions.handle_shield_collision(projectile, tile_map, delta, projectiles.enemy_projectiles, 1, PROJECTILESPEED)
			#
	
# main game loop
func _process(delta):
	if enemies.enemies.is_empty(): # reloading the scene
		
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		
	if running:
		
		# speeding up the invaders
		if enemies.enemies.size() == 1:
			game_loop_timer.wait_time = 0.1
			enemies.invader_distance = 30
		elif enemies.enemies.size() <= 10:
			game_loop_timer.wait_time = 0.5
			enemies.invader_distance = 20
		elif enemies.enemies.is_empty():
			game_loop_timer.stop( )
		
		# formatting the lives images
		if GlobleVars.lives == 2:
			life_1.visible = false
		if GlobleVars.lives == 1:
			life_1.visible = false
			life_2.visible = false
			

		#ufo
		if ufo.get_node("ufoSprite").visible and ufo.get_node("timer/intervalTimer").is_stopped():
			ufo.move_ufo()
	
		# SCORE
		score_label.text = text.format_score(GlobleVars.score)
		lives_label.text = str(GlobleVars.lives)
		
		if enemies.reached_bottom():
			GlobleVars.lives = 0
		
	
	# if death
	if GlobleVars.lives == 0:
		
		game_loop_timer.stop()
		player.get_node("playerExplosionAnimation").visible = true
		player.get_node("playerSprite").visible = false
		ufo.get_node("timer/spawnTimer").stop()
		
		running = false
		if not game_over_label.visible:
			text.draw_text("GAME OVER", game_over_label)
		game_over_label.visible = true
		

		# check and update the high score
		if GlobleVars.score > GlobleVars.high_score:
			GlobleVars.high_score = GlobleVars.score
		
		GlobleVars.high_score_str = text.format_score(GlobleVars.high_score)
		
		if Input.is_action_just_pressed("shoot"):
			GlobleVars.lives = 3 # reset lives, 
			game_over_label.visible = false
			GlobleVars.score = 0 # reset the score
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	
	
	
		
	

# leave here
func _on_shooting_interval_timeout() -> void:     
	enemies.activate_shooting()
