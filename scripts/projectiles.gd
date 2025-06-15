extends Node

@onready var game_manager: GameManager = %GameManager

const number_of_enemy_projectiles: int = 12
const PROJECTILE = preload("res://scenes/projectile.tscn")

var enemy_projectiles: Array = []

func initialize_projectiles():
	for i in range(number_of_enemy_projectiles):
		var enemy_projectile = PROJECTILE.instantiate();
		enemy_projectile.id = i % 3 # the 3 if how many animations I have
		enemy_projectile.position = game_manager.hidden_coord # move this into a global varaible
		
		add_child(enemy_projectile)
		enemy_projectiles.append(enemy_projectile)


func get_random_projectile():
	enemy_projectiles.shuffle()
	for projectile in enemy_projectiles:
		if Vector2i(projectile.position) == game_manager.hidden_coord:
			return projectile
		
