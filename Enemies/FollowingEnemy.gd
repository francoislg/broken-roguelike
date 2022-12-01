extends BaseEnemy

const BASE_SPEED = 100
# The higher this is, the faster the enemy will get to speed
const TIME_TO_GET_TO_SPEED = 500

func _physics_process(delta):
	var vector = (character.position - position).normalized()
	
	velocity = velocity.move_toward(vector * BASE_SPEED, delta * TIME_TO_GET_TO_SPEED)
	
	move_and_collide(velocity * delta)

