extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $animation
@onready var default: Sprite2D = $default

var id: int = 3

# when enters the scene tree for the first time
func _ready():
	
	match id:
		0: 
			animation.play("A")
		1:
			animation.play("B")
		2:
			animation.play("C")
		_:
			default.visible = true
			
			
			
			
	
	
