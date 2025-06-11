extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var projectile: CharacterBody2D = $"../projectile"
@onready var invincible_timer: Timer = $invincibleTimer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D


const SPEED: int = 300
var invincible: bool = false

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
		
		


func _on_area_2d_body_entered(p: CharacterBody2D) -> void:
	
	if not invincible:
		invincible = true
		invincible_timer.start(1)
		p.position = Vector2i(1000, 1000)
		game_manager.enemy_projectiles.erase(p)
		GlobleVars.lives -= 1
	
	


func _on_invincible_timer_timeout() -> void:
	invincible = false
