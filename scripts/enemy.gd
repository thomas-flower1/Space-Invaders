extends Area2D

@onready var game_manager: GameManager = get_node("/root/Main/GameManager")
@onready var enemies: Node = get_parent()
@onready var death_sound: AudioStreamPlayer2D = $death_sound


@onready var ray_cast_right: RayCast2D = $rayCastRight
@onready var ray_cast_left: RayCast2D = $rayCastLeft
@onready var ray_cast_bottom: RayCast2D = $rayCastBottom

@onready var animation: AnimatedSprite2D = $animation

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
	
	projectile.position = game_manager.hidden_coord
	death_sound.play()
	
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
	
	enemies.enemies.erase(self)
	queue_free()
	
