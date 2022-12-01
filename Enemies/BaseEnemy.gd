extends CharacterBody2D

class_name BaseEnemy

@onready var health := $Health
@onready var character: CharacterBody2D = $"/root/Scene/Character"

var initialHp: float = 5
var hp: float

func _ready():
	hp = initialHp
	update_progress_bar(1)

func _process(delta):
	pass

func receive_damage(direction: Vector2, damage: float):
	hp -= damage
	if hp <= 0:
		queue_free()
	else:
		velocity = direction * 200
		update_progress_bar(hp / initialHp)
		

func update_progress_bar(ratio: float):
	health.value = ratio * 100
	var r = lerpf(1, 0, ratio)
	var g = lerpf(0, 1, ratio)
	health.set("modulate", Color(r, g, 0))
