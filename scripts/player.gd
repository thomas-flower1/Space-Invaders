extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var lives_label = $"../../text/lives"
@onready var projectile: CharacterBody2D = $"../projectile"


const SPEED: int = 300

# pre defined function
func _physics_process(delta) -> void:
	if game_manager.running:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		
		
	

func _input(event)-> void:
	'''
	Checking for space bar input
	If space bar is pressed and there is no projectile, create one and add to the scene tree
	Adds the node under player node
	'''

	if event.is_action_pressed("shoot") and game_manager.running and game_manager.player_projectiles.is_empty(): # if we have no projectile on the screen
		projectile.position = position 
		game_manager.player_projectiles.append(projectile)
		
		



func _on_player_collision_body_entered(body):
	game_manager.lives -= 1
	lives_label.text = str(game_manager.lives)
	
	# need to remove from the projeciles array
	game_manager.enemy_projectiles.erase(body)
	body.postion = game_manager.hidden_coord
	
	
	
	
