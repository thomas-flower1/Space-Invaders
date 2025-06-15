extends Node

@onready var game_manager: GameManager = %GameManager
@onready var explosion_timer: Timer = $explosionTimer
@onready var explosion: AnimatedSprite2D = $explosion

const explosion_duration: float = 0.3


func get_destroy_pattern() -> Array:
	
	var destroy_patterns = [
		[
		[0, 1, 1, 0, 1],
		[1, 1, 1, 0, 1],
		[1, 1, 1, 1, 0],
		[0, 1, 1, 1, 1],
		[0, 1, 0, 0, 1], 
		], 
		
		[
			[1, 0, 0, 0, 1],
			[1, 1, 1, 1, 1],
			[0, 1, 1, 1, 0],
			[0, 1, 0, 1, 0],
			[1, 1, 0, 0, 1], 
		], [
		
			[0, 1, 0, 1, 0],
			[1, 1, 1, 1, 1],
			[0, 1, 1, 1, 0],
			[1, 1, 1, 1, 1],
			[0, 1, 0, 1, 0], 
			]
		
		]
	
	var random_index = randi_range(0, destroy_patterns.size()-1)
	
	return destroy_patterns[random_index]

func remove_tile_explosion(coord: Vector2i, tile_map: TileMap):
		var object_coord: Vector2i = tile_map.local_to_map(coord) # gets the corresponding coord in the map
		var map_coord: Vector2i = tile_map.get_cell_atlas_coords(0, object_coord) # will return either a valid or invalid tile
		
		if map_coord == Vector2i(-1, -1): #if there is no tile there
			return false
		
		var start_vector: Vector2i = object_coord - Vector2i(1, -1) # gets a diagonal and to the right tile
		var y = start_vector.y
		var destroy_pattern = get_destroy_pattern();
		for row in destroy_pattern:
			var x = start_vector.x
			for col in row:
				if col == 1:
					tile_map.erase_cell(0, Vector2i(x, y))
				x += 1
			y -=1
		
		return true


func handle_shield_collision(projectile: CharacterBody2D, tile_map: TileMap, delta: float, projectile_array: Array, direction: int, speed: int) -> void:
	
	# TODO add collisions between the two projectiles


	var distance = Vector2(0, direction * speed * delta) # calculate the distance in which we want to move the projecile
	var collision = projectile.move_and_collide(distance) # move the projectile this disance and check for collisions
	
	
	# first checking to see if off screen
	if projectile.position.y < -256:
		# want to add the explosion animation too
		explosion.visible = true
		explosion.position = projectile.position
		explosion_timer.start(explosion_duration)
		
	
		projectile.position = game_manager.hidden_coord
		return 
	
	elif projectile.position.y > 352:
		var map_coord = tile_map.local_to_map(Vector2i(projectile.position.x, 352))
		tile_map.erase_cell(0, map_coord)
		
	
		projectile.position = game_manager.hidden_coord
		
		
		
		return 
		
	
	if collision:
		var collision_coord = Vector2i(collision.get_position())
		
		
		
		var top_right: Vector2i = collision_coord - Vector2i(1, 1) 
		var top_left: Vector2i = collision_coord - Vector2i(-1, 1)
		var top_middle: Vector2i = collision_coord - Vector2i(0, 1) 
		
		var bottom_middle: Vector2i = collision_coord + Vector2i(0, 1)
		var bottom_left: Vector2i = collision_coord + Vector2i(-1, 1)
		var bottom_right: Vector2i = collision_coord + Vector2i(1, 1)
			
		

		if valid_tile(top_middle, tile_map):
			remove_tile_explosion(top_middle, tile_map)
			
			projectile.position = game_manager.hidden_coord
			return
			
		elif valid_tile(top_left, tile_map):
			remove_tile_explosion(top_left, tile_map)
			
			projectile.position = game_manager.hidden_coord
			return 
		
		elif valid_tile(top_right, tile_map):
			remove_tile_explosion(top_right, tile_map)
		
			projectile.position = game_manager.hidden_coord
			return 
		
		elif valid_tile(bottom_left, tile_map):
			remove_tile_explosion(bottom_left, tile_map)
			
			projectile.position = game_manager.hidden_coord
			return 
		
		elif valid_tile(bottom_middle, tile_map):
			remove_tile_explosion(bottom_middle, tile_map)
			projectile.position = game_manager.hidden_coord
			return 
		
		elif valid_tile(bottom_right, tile_map):
			remove_tile_explosion(bottom_right, tile_map)
			
			projectile.position = game_manager.hidden_coord
			return
		
		
		
		elif collision.get_collider().name == "player":

			projectile.position = game_manager.hidden_coord
		
			return 
			
	
		
	
		
func valid_tile(coord: Vector2i, tile_map: TileMap) -> bool:
	var object_coord: Vector2i = tile_map.local_to_map(coord) # gets the corresponding coord in the map
	if tile_map.get_cell_atlas_coords(0, object_coord) == Vector2i(-1, -1):
		return false
	return true
	

func _on_explosion_timer_timeout() -> void:
	explosion.visible = false
