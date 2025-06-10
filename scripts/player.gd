extends CharacterBody2D

@onready var PROJECTILE = load("res://scenes/projectile.tscn") # reference to the scene to instantiate later
@onready var main = $"../.." # path to the main node
@onready var tile_map = $"../../TileMap"
@onready var game_manager = %GameManager
@onready var lives_label = $"../../text/lives"
@onready var explosion = $"../explosion"
@onready var explosion_timer = $explosion_timer
@onready var character_functions: Node = $"../../Character Functions"


const SPEED: int = 300
const BULLETSPEED: int = 950 #950


var projectile: CharacterBody2D = null
var lives: int = 3
var explosion_animation_time: float = 0.3


# pre defined function
func _physics_process(delta) -> void:
	if game_manager.running:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		if is_instance_valid(projectile) and projectile:
			var distance = Vector2(0, -900 * delta) # calculate the distance in which we want to move the projecile
			var collision = projectile.move_and_collide(distance) # move the projectile this disance and check for collisions
			
			if collision:
				var collision_pos = Vector2i(collision.get_position()) - Vector2i(0, 1) # we want to check the coord one above the collision
				var object_coord: Vector2i = tile_map.local_to_map(collision_pos) # gets the corresponding coord in the map
				var map_coord: Vector2i = tile_map.get_cell_atlas_coords(0, object_coord) # will return either a valid or invalid tile
				
				character_functions.remove_tile_explosion(collision_pos, tile_map) # remove multiple tiles
				main.remove_child(projectile) # if there is a tile there remove the projectile
				projectile = null 
			
			
			# if the projectile is off the sceen remove it
			elif projectile.position.y < -256:
				explosion.visible = true
				explosion.position.x = projectile.position.x
				explosion_timer.start(explosion_animation_time)
				projectile.queue_free()
				projectile = null
	
	
	

func _input(event)-> void:
	'''
	Checking for space bar input
	If space bar is pressed and there is no projectile, create one and add to the scene tree
	'''
	
	if event.is_action_pressed("shoot") and game_manager.running and not projectile: # if we have no projectile on the screen
		var p = PROJECTILE.instantiate() # make a new instance of the projectile scene
		p.position = Vector2(position.x, position.y) # set the projectile postion to the player pos
		main.add_child(p) # add to the scene tree
		projectile = p # give global scope



func _on_player_collision_body_entered(body):
	lives -= 1
	lives_label.text = str(lives)
	game_manager.enemy_projectiles.erase(body)
	body.queue_free()
	
	
func _on_explosion_timer_timeout():
	explosion.visible = false
