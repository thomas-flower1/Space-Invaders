extends CharacterBody2D

const SPEED = 300.0
const BULLETSPEED = 300

var projectiles = []


var justShot = false # for the cooldown
@onready var projectile = load("res://scenes/projectile.tscn") # reference to the scene to instantiate later
@onready var main = $"../.." # path to the main node
@onready var timer = $Timer
@onready var tile_map = $"../../TileMap2"

@onready var gameManager = %GameManager

@onready var lives = $"../../text/lives"




# pre defined function
func _physics_process(delta):
	if gameManager.running:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()



func _input(event):
	if event.is_action_pressed("shoot") and not justShot: # if space and we have no cooldown
		cooldown() # start the cooldown
		var p = projectile.instantiate() # make a new instance of the projectile scene
		
		p.position = Vector2(position.x, position.y) # set the projectile postion to the player pos
		
		main.add_child(p) # add to the scene tree
	
		
		projectiles.append(p) # add to the global main keeping track

# each fram
func _process(delta):
	
	# for every projectile in the projectiles, update the pos
	if not projectiles.is_empty(): 
		for projectile in projectiles:
			projectile.position.y -= BULLETSPEED * delta

			# if the projectile is off the sceen remove it
			if projectile.position.y < -256:
				projectiles.pop_front()
				projectile.queue_free()
	
	# checking for collision between player projeectile and the shields
	
			var projectileCoord: Vector2i = tile_map.local_to_map(projectile.position) # gets the corresponding coord in the map
			var otherProjectileCoords: Vector2i = tile_map.local_to_map(Vector2i(projectile.position.x, projectile.position.y + 1))
			
		
			var mapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, projectileCoord) # getting the coord in the tilemap of where the projectile is
			var otherMapCoord: Vector2i = tile_map.get_cell_atlas_coords(0, otherProjectileCoords)
			if mapCoord != Vector2i(-1, -1) or mapCoord != Vector2i(-1, -1):
				tile_map.erase_cell(0, projectileCoord)
				tile_map.erase_cell(0, otherProjectileCoords)
				main.remove_child(projectile) # if there is a tile there remove the projectile
				projectiles.erase(projectile)
				
				
		
			
			
# start a cooldown
func cooldown():
	if not justShot:
		justShot = true
		timer.start()


func _on_timer_timeout():
	justShot = false
	


func _on_player_collision_body_entered(body):
	lives.text = str(int(lives.text) - 1)
	gameManager.enemyProjectiles.erase(body)
	body.queue_free()
	
	gameManager.running = false # make it so that the game is not running
	
	
