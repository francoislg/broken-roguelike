extends Weapon

@onready var Pivot := $Pivot
@onready var Ball = $Pivot/Ball
@onready var AttackArea = $Pivot/Ball/AttackArea
@onready var Explosion := $Pivot/Ball/AttackArea/Explosion
@onready var Orbit := $Pivot/Ball/Collision/Orbit

var respawnTimer = Timer.new()
var attackingTimer = Timer.new()

var original_position

func _ready():
	# Add some randomness if we have 2 bullets weapons
	add_child(Timers.initOneShotTimer(respawnTimer, "respawn", randf_range(0.1, playerVariables.projectileCooldown), respawn))
	add_child(Timers.initOneShotTimer(attackingTimer, "attacking", 0.5, attacking_end))

func _process(delta):
	if attackingTimer.is_stopped():
		Pivot.rotate(delta * 10)

func respawn():
	Orbit.visible = true

func explode():
	Orbit.visible = false
	Explosion.visible = true
	original_position = AttackArea.position
	
	attackingTimer.start()
	respawnTimer.start(playerVariables.projectileCooldown)
	call_deferred("set_global")

func attacking_end():
	Explosion.visible = false
	call_deferred("revert_global")

func set_global():
	# There is certainly a better way to "detach" the global position, but this should work for now
	AttackArea.reparent(get_tree().root)
	
func revert_global():
	AttackArea.reparent(Ball)
	AttackArea.position = Vector2.ZERO

func _on_collision_body_entered(body):
	if respawnTimer.is_stopped() and body is BaseEnemy:
		var enemies = AttackArea.get_overlapping_bodies().filter(func(body): return body is BaseEnemy)
		for enemy in enemies:
			damage_enemy(enemy)
			
		explode()

func _on_attack_area_body_entered(body):
	if not attackingTimer.is_stopped() and body is BaseEnemy:
		damage_enemy(body)

func damage_enemy(enemy: BaseEnemy):
	var enemyHitDirection = (enemy.position - Character.position).normalized()
	enemy.receive_damage(enemyHitDirection, playerVariables.projectileDamage)

