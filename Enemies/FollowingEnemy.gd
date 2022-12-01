extends CharacterBody2D

@onready var character: CharacterBody2D = $"/root/Scene/Character"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var vector = (character.position - position).normalized()
	
	velocity = vector * 2000 * delta
	
	move_and_slide()
