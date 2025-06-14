extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var projectile: CharacterBody2D = $"../projectile"
@onready var invincible_timer: Timer = $invincibleTimer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var player_explosion: AnimatedSprite2D = $playerExplosion
@onready var player_sprite: Sprite2D = $playerSprite
@onready var death_reset: Timer = $deathReset
@onready var shoot_sound: AudioStreamPlayer2D = $"../../audio/shoot_sound"
@onready var player_death_sound: AudioStreamPlayer2D = $"../../audio/player_death_sound"

@onready var ray_cast_right: RayCast2D = $rayCastRight
@onready var ray_cast_left: RayCast2D = $rayCastLeft

 
var invincible: bool = false
const death_time: int = 2


# pre defined function
func _physics_process(delta: float) -> void:
	if game_manager.running:
		if Input.is_action_pressed("right") and not ray_cast_right.is_colliding():
			position.x += 1 * 4

		elif Input.is_action_pressed("ui_left") and not ray_cast_left.is_colliding():
			position.x += - 1 * 4
 
		
	

func _input(event)-> void:
	'''
	Checking for space bar input
	If space bar is pressed and there is no projectile, create one and add to the scene tree
	Adds the node under player node
	'''

	if event.is_action_pressed("shoot") and game_manager.running and Vector2i(projectile.position) == game_manager.hidden_coord: # if we have no projectile on the screen
		projectile.position = position 
		shoot_sound.play()
		
		
		
		


func _on_area_2d_body_entered(p: CharacterBody2D) -> void:
	
	if not invincible:
		invincible = true
		invincible_timer.start(3)
		p.position = Vector2i(1000, 1000)
		GlobleVars.lives -= 1
		
		player_death_sound.play()
		
		# TODO pause the game, also need to update the image
		player_sprite.visible = false
		player_explosion.visible = true
		player_explosion.play()
		
		game_manager.running = false
		
		# TODO do a timer to reset these
		death_reset.start(death_time)
		
		for projectile in game_manager.enemy_projectiles:
			projectile.position = game_manager.hidden_coord
		
	
func _on_invincible_timer_timeout() -> void:
	invincible = false



func _on_death_reset_timeout() -> void:
	game_manager.running = true
	player_explosion.visible = false
	player_sprite.visible = true
