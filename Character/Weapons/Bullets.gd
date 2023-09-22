extends Weapon

var projectileTimer = Timer.new()

func _ready():
	# Add some randomness if we have 2 bullets weapons
	add_child(Timers.initTimer(projectileTimer, "projectile", randf_range(0.1, playerVariables.projectileCooldown), _on_timer_projectile))
	projectileTimer.start()
	Character.connect("receive_damage", _on_receive_damage)
	Character.connect("received_damage_end", _on_receive_damage_end)

func _on_receive_damage():
	projectileTimer.stop()

func _on_receive_damage_end():
	_on_timer_projectile()
	projectileTimer.start()

func _on_timer_projectile():
	var enemy = EnemiesTracker.get_closest_to(Character.position)
	var direction = (enemy.position - Character.position).normalized() if enemy else (Vector2.LEFT if Character.sprite.flip_h else Vector2.RIGHT)
	ProjectileSpawner.create_projectile(Character.position + (Vector2.UP * 10), direction * 1000, playerVariables.projectileDamage)
	projectileTimer.wait_time = playerVariables.projectileCooldown
