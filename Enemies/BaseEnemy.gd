extends CharacterBody2D

class_name BaseEnemy

@onready var character: CharacterBody2D = $"/root/Scene/Character"

var hp: float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receive_damage(direction: Vector2, damage: float):
	hp -= damage
	if hp <= 0:
		queue_free()
	else:
		velocity = direction * 200
