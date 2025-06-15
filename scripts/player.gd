extends CharacterBody2D


@onready var game_manager = %GameManager
@onready var projectile: CharacterBody2D = $"../projectile"
@onready var projectiles: Node = $"../../projectiles"


# Sprites
@onready var player_explosion_animation: AnimatedSprite2D = $playerExplosionAnimation
@onready var player_sprite: Sprite2D = $playerSprite

# Timers
@onready var invincible_timer: Timer = $timers/invincibleTimer
@onready var death_reset_timer: Timer = $timers/deathResetTimer

# Audio
@onready var player_death_sound: AudioStreamPlayer2D = $audio/player_death_sound
@onready var shoot_sound: AudioStreamPlayer2D = $audio/shoot_sound

# Raycasts
@onready var ray_cast_right: RayCast2D = $rayCastRight
@onready var ray_cast_left: RayCast2D = $rayCastLeft



const death_time: int = 2
var invincible: bool = false # gets a couple of iframes after hit


# Player movement
func _physics_process(delta: float) -> void:
	if game_manager.running:
		if Input.is_action_pressed("right") and not ray_cast_right.is_colliding():
			position.x += 1 * 4

		elif Input.is_action_pressed("ui_left") and not ray_cast_left.is_colliding():
			position.x += - 1 * 4
 
		
	

func _input(event)-> void:
	
	# handling shooting
	if event.is_action_pressed("shoot") and game_manager.running and Vector2i(projectile.position) == game_manager.hidden_coord: # if we have no projectile on the screen
		projectile.position = position 
		shoot_sound.play()
		

func _on_area_2d_body_entered(enemy_projectile: CharacterBody2D) -> void:
	
	# when an emeny projectile collides with the player
	if not invincible:
		GlobleVars.lives -= 1
		
		invincible = true # give iframes
		invincible_timer.start(3)
		
		enemy_projectile.position = game_manager.hidden_coord # hide enemy projectile
		
		player_death_sound.play()
		
		player_sprite.visible = false
		player_explosion_animation.visible = true # the explostion it autoplaying
		
		game_manager.running = false # pause the game briefly
		
		death_reset_timer.start(death_time)
		
		for projectile in projectiles.enemy_projectiles: # reset all the projectiles
			projectile.position = game_manager.hidden_coord
		
	
func _on_invincible_timer_timeout() -> void:
	invincible = false


func _on_death_reset_timer_timeout() -> void:
	
	# game resumes after a few seconds
	game_manager.running = true
	player_explosion_animation.visible = false
	player_sprite.visible = true
