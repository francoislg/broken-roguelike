extends BaseRespawnStrategy

@export var numberOfRespawns: int = -1
@export var timeToRespawnInSec: float = 5
var remainingRespawns := numberOfRespawns
var enemies = []
var numberAlive = 0

func on_ready(_enemies):
	enemies = _enemies
	remainingRespawns = numberOfRespawns
	
	numberAlive = len(enemies)
	
	for enemy in enemies:
		enemy.disable_free_on_death()
		enemy.connect("dies", on_enemy_dies)
	
func on_enemy_dies():
	numberAlive -= 1
	if numberAlive <= 0:
		if remainingRespawns == -1 or remainingRespawns > 0:
			if remainingRespawns != -1:
				remainingRespawns -= 1;
			var timer = Timer.new()
			timer.one_shot = true
			timer.autostart = true
			timer.wait_time = timeToRespawnInSec;
			timer.connect("timeout", respawnAll)
			add_child(timer)
			
func respawnAll():
	for enemy in enemies:
		enemy.respawn()
