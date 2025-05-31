extends CharacterBody2D

@onready var PROJECTILE = load("res://scenes/projectile.tscn") # reference to the scene to instantiate later
@onready var main = $"../.." # path to the main node
@onready var tile_map = $"../../TileMap2"
@onready var game_manager = %GameManager
@onready var lives_label = $"../../text/lives"

const SPEED: int = 300
const BULLETSPEED: int = 1000

var projectile: CharacterBody2D = null
var lives: int = 3


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
	
	# for every projectile in the projectiles, update the pos
	if is_instance_valid(projectile) and projectile:
		projectile.position.y -= BULLETSPEED * delta 
		
		var projectileCoord: Vector2i = tile_map.local_to_map(projectile.position) # gets the corresponding coord in the map
		var otherProjectileCoords: Vector2i = tile_map.local_to_map(Vector2i(projectile.position.x, projectile.position.y + 1))
		var mapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, projectileCoord) # getting the coord in the tilemap of where the projectile is
		var otherMapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, otherProjectileCoords)
		
		if mapCoord != Vector2i(-1, -1) or mapCoord != Vector2i(-1, -1):
			# TODO do an explosion to remove mutliple cells
			
			tile_map.erase_cell(0, projectileCoord)
			tile_map.erase_cell(0, otherProjectileCoords)
			main.remove_child(projectile) # if there is a tile there remove the projectile
			projectile = null 

		# if the projectile is off the sceen remove it
		if projectile.position.y < -256:
			projectile.queue_free()
			projectile = null
			


func _on_player_collision_body_entered(body):
	lives -= 1
	lives_label.text = str(lives)
	game_manager.enemy_projectiles.erase(body)
	body.queue_free()
	game_manager.running = false # make it so that the game is not running
	
	
	
