extends Node

const Projectile = preload("res://Character/Projectile.tscn")

func create_projectile(spawn_point: Vector2, direction: Vector2, damage: float):
	var projectile := Projectile.instantiate()
	projectile.global_position = spawn_point
	projectile.linear_velocity = direction
	projectile.damage = damage
	add_child(projectile)

func reset():
	for child in get_children():
		remove_child(child)
