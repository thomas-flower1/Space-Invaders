extends Area2D

@onready var game_manager: GameManager = get_parent()
@onready var ray_cast_right = $rayCastRight
@onready var ray_cast_left = $rayCastLeft
@onready var animation = $animation
@onready var ray_cast_bottom: RayCast2D = $rayCastBottom
@onready var death_delay: Timer = $deathDelay
@onready var explosion: AnimatedSprite2D = $explosion


var type: int = 1 # the type of enemy it is
var score: int # the score value
var delay: float = 0.3



# when the enemy is created, assign the animation with the type
func _ready():
	if type == 1:
		animation.play("enemy1")
	elif type == 2:
		animation.play("enemy2")
	else:
		animation.play("enemy3")
	
	animation.stop() # pause the animation until the game starts
	

func _on_body_entered(projectile: CharacterBody2D) -> void:
	'''
	When a player projectile enters the enemy body
	Play an animation, delete the projecile, wait, then delete the enemy
	
	'''
	
	# need to remove the projectile
	game_manager.player_projectiles.erase(projectile)
	projectile.position = game_manager.hidden_coord
	
	animation.visible = false
	explosion.visible = true
	GlobleVars.score += score
	
	death_delay.start(delay)
	
	
		
func colliding_left() -> bool:
	return ray_cast_left.is_colliding()

func colliding_right() -> bool:
	return ray_cast_right.is_colliding()
		
func colliding_bottom() -> bool:
	return ray_cast_bottom.is_colliding()


func _on_death_delay_timeout() -> void:
	game_manager.enemies.erase(self)
	queue_free()
	
