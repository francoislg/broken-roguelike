extends Node

class_name EnemiesTracker

var enemies: Array[BaseEnemy] = []

func add(enemy: BaseEnemy):
	enemies.append(enemy)
	
func remove(enemy: BaseEnemy):
	enemies.erase(enemy)

func get_closest_to(point: Vector2):
	var tuple = enemies.reduce(func(currentTuple, enemy):
		var dist = point.distance_to(enemy.position)
		if dist < currentTuple[1]:
			return [enemy, dist]
		else:
			return currentTuple
	, [null, INF])
	return tuple[0]
