@tool

extends Prop

class_name Respawner

@onready var RespawnStrategy = $Strategy
@onready var StaticRespawnPoint = $StaticRespawnPoint

func _ready():
	assert(RespawnStrategy != null, "Error: You must have a respawn strategy with this node")
	assert(RespawnStrategy is BaseRespawnStrategy, "Error: The strategy must inherit BaseRespawnStrategy")
	var enemies = get_children().filter(func(enemy): return enemy is BaseEnemy) as Array[BaseEnemy]
	if RespawnStrategy is BaseRespawnStrategy:
		if StaticRespawnPoint != null:
			for enemy in enemies:
				enemy.initialPosition = StaticRespawnPoint.position
		RespawnStrategy.on_ready(enemies)

