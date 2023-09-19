extends Node

class_name WavesStage

signal stage_win

## Adds to the number of enemies
@export_range(0, 10, 1) var addition: int = 0
## Multiplies to the number of enemies, after the addition, rounded down. (e.g. multiplier = 1.5, addition = 1, total = floor((1 + (nb)) * 1.5))
@export_range(1, 10, 0.5, " * (totalNumberOfEnemies + plus)") var multiplier: float = 1

@onready var Enemies := $"../../Enemies"
@onready var StageLabel := $"../../UI/StageLabel"

var numberOfEnemies: int = addition

func do_ready():
	for enemy in Enemies.get_children().filter(func(c): return c is BaseEnemy):
		numberOfEnemies += 1
		enemy.connect("dies", on_enemy_dies)
	numberOfEnemies = floor(numberOfEnemies * max(multiplier, 1))
	updateLabel()

func do_process(_delta):
	pass

func on_enemy_dies():
	numberOfEnemies -= 1
	
	updateLabel()
	
	if numberOfEnemies <= 0:
		emit_signal('stage_win')

func updateLabel():
	StageLabel.text = "Ennemies Left: %s" % numberOfEnemies
