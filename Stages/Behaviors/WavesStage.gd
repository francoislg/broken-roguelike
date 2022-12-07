extends Node

class_name WavesStage

signal stage_win

@onready var Enemies := $"../../Enemies"

var numberOfEnemies := 0

func do_ready():
	for enemy in Enemies.get_children().filter(func(c): return c is BaseEnemy):
		numberOfEnemies += 1
		enemy.connect("dies", on_enemy_dies)

func do_process(_delta):
	pass

func on_enemy_dies():
	numberOfEnemies -= 1
	if numberOfEnemies <= 0:
		emit_signal('stage_win')
