extends CharacterBody2D

@onready var PROJECTILE = load("res://scenes/projectile.tscn") # reference to the scene to instantiate later
@onready var main = $"../.." # path to the main node
@onready var tile_map = $"../../TileMap2"
@onready var game_manager = %GameManager
@onready var lives_label = $"../../text/lives"
@onready var explosion = $"../explosion"
@onready var explosion_timer = $explosion_timer


const SPEED: int = 300
const BULLETSPEED: int = 950 #950


var projectile: CharacterBody2D = null
var lives: int = 3
var explosion_animation_time: float = 0.3


# TODO make multiple destroy patterns
var destroy_pattern: Array = [
	[0, 1, 1, 0, 1],
	[1, 1, 1, 0, 1],
	[1, 1, 1, 1, 0],
	[0, 1, 1, 1, 1],
	[0, 1, 0, 0, 1], 
]



# pre defined function
func _physics_process(_delta):
	if game_manager.running:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()



func _input(event):
	if event.is_action_pressed("shoot") and game_manager.running and projectile == null: # if space and we have no cooldown
		var p = PROJECTILE.instantiate() # make a new instance of the projectile scene
		p.position = Vector2(position.x, position.y) # set the projectile postion to the player pos
		main.add_child(p) # add to the scene tree
		projectile = p # give global scope
		

# each frame
func _process(delta):
	
	# if a projectile exists
	if is_instance_valid(projectile) and projectile:
		projectile.position.y -= BULLETSPEED * delta 
		
		
		var projectile_coord: Vector2i = tile_map.local_to_map(projectile.position) # gets the corresponding coord in the map
		var map_coord: Vector2i = tile_map.get_cell_atlas_coords(0, projectile_coord) # will return either a valid or invalid tile
		
		if map_coord != Vector2i(-1, -1): 
			# TODO add an explostion animation
			
	
			var start_vector: Vector2i = projectile_coord - Vector2i(1, -1)
			var y = start_vector.y
			
			for row in destroy_pattern:
				var x = start_vector.x
				for col in row:
					if col == 1:
						tile_map.erase_cell(0, Vector2i(x, y))
					
					x += 1
				y -=1
			
			
			#tile_map.erase_cell(0, projectile_coord);
			main.remove_child(projectile) # if there is a tile there remove the projectile
			projectile = null 

		# if the projectile is off the sceen remove it
		elif projectile.position.y < -256:
			explosion.visible = true
			explosion.position.x = projectile.position.x
			explosion_timer.start(explosion_animation_time)
			projectile.queue_free()
			projectile = null
			


func _on_player_collision_body_entered(body):
	lives -= 1
	lives_label.text = str(lives)
	game_manager.enemy_projectiles.erase(body)
	body.queue_free()
	game_manager.running = false # make it so that the game is not running
	
	
	
func _on_explosion_timer_timeout():
	explosion.visible = false
