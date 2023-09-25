extends Weapon

@onready var Collision = $Collision
@onready var Cross = $Cross

var attackTimer = Timer.new()
var crossVisibleTimer = Timer.new()

var isAttacking = false

func _ready():
	# Add some randomness if we have 2 bullets weapons
	add_child(Timers.initOneShotTimer(attackTimer, "attack", randf_range(0.1, playerVariables.meleeCooldown), on_attack_timer))
	add_child(Timers.initOneShotTimer(crossVisibleTimer, "cross_visible", 0.5, _on_cross_timer_end))
	attackTimer.start()
	Character.connect("receive_damage", _on_receive_damage)
	Character.connect("received_damage_end", _on_receive_damage_end)

func _on_cross_timer_end():
	isAttacking = false
	Cross.visible = false

func _on_receive_damage():
	isAttacking = false
	attackTimer.stop()

func _on_receive_damage_end():
	trigger_attack_timer()

func on_attack_timer():
	Cross.visible = true
	crossVisibleTimer.start()
	
	isAttacking = true
	
	var hitEnemies = Collision.get_overlapping_bodies().filter(func(body): return body is BaseEnemy)
		
	for enemy in hitEnemies:
		damage_enemy(enemy)
		
	trigger_attack_timer()
	
func trigger_attack_timer():
	attackTimer.start(playerVariables.meleeCooldown)

func _on_collision_body_entered(body):
	if isAttacking and body is BaseEnemy:
		damage_enemy(body)

func damage_enemy(enemy: BaseEnemy):
	var enemyHitDirection = (enemy.position - Character.position).normalized()
	enemy.receive_damage(enemyHitDirection, playerVariables.meleeDamage * 2)



