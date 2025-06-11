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
const BULLETSPEED: int = 1500


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
		
		# Collison with the shield logic
		if is_instance_valid(projectile) and projectile:
			
			var distance = Vector2(0, -1 * BULLETSPEED * delta) # calculate the distance in which we want to move the projecile
			var collision = projectile.move_and_collide(distance) # move the projectile this disance and check for collisions
			
			if collision:
				
				# checking the tile above, top right, top left
				var top_right: Vector2i = Vector2i(collision.get_position())- Vector2i(1, 1) 
				var top_left: Vector2i = Vector2i(collision.get_position()) - Vector2i(-1, 1)
				var top_middle: Vector2i = Vector2i(collision.get_position()) - Vector2i(0, 1) 
				
				
				if valid_tile(top_middle):
					character_functions.remove_tile_explosion(top_middle, tile_map)
					main.remove_child(projectile) # if there is a tile there remove the projectile
					projectile.queue_free()
					projectile = null 
					
				elif valid_tile(top_left):
					character_functions.remove_tile_explosion(top_left, tile_map)
					main.remove_child(projectile) # if there is a tile there remove the projectile
					projectile.queue_free()
					projectile = null 
				#
				elif valid_tile(top_right):
					character_functions.remove_tile_explosion(top_right, tile_map)
					main.remove_child(projectile) # if there is a tile there remove the projectile
					projectile.queue_free()
					projectile = null 


			# if the projectile is off the sceen remove it
			elif projectile.position.y < -256:
				explosion.visible = true
				explosion.position.x = projectile.position.x
				explosion_timer.start(explosion_animation_time)
				projectile.queue_free()
				projectile = null
	
func valid_tile(coord: Vector2i) -> bool:
	var object_coord: Vector2i = tile_map.local_to_map(coord) # gets the corresponding coord in the map
	if tile_map.get_cell_atlas_coords(0, object_coord) == Vector2i(-1, -1):
		return false
	return true
	
	
	

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
