extends Node

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
		
