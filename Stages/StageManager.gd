@tool
extends Node

@export_flags("Coins", "Waves") var supported_types = StageTypes.types.Coins | StageTypes.types.Waves

@onready var Coins := $Coins
@onready var Enemies := $Enemies
@onready var Walls := $Walls
@onready var Character := %Character
@onready var StartingPoint := $StartingPoint

@export var editorType: StageTypes.types:
	set(type):
		if type != editorType:
			editorType = type
			if Engine.is_editor_hint():
				set_visibility_for_stage_type(type)

var currentType: StageTypes.types = StageTypes.types.Coins

func _ready():
	set_visibility_for_stage_type(StageTypes.types.Coins | StageTypes.types.Waves)
	
	var arrayOfSupportedTypes = [
		supported_types & StageTypes.types.Coins != 0,
		supported_types & StageTypes.types.Waves != 0, 
	]
	currentType = StageTypes.types.values()[randi_range(0, arrayOfSupportedTypes.size() - 1)]
	set_up_stage()
	
func set_up_stage():
	Character.position = StartingPoint.position
	
	for enemy in Enemies.get_children().filter(func(enemy): return enemy is BaseEnemy):
		if enemy.stage_layer & currentType == 0:
			Enemies.remove_child(enemy)
			
	for floorOrWall in Walls.get_children().filter(func(wall): return wall is FloorOrWall):
		if floorOrWall.stage_layer & currentType == 0:
			Walls.remove_child(floorOrWall)
	
	if currentType & StageTypes.types.Coins == 0:
		remove_child(Coins)

func set_visibility_for_stage_type(type: StageTypes.types):
	for enemy in Enemies.get_children().filter(func(enemy): return enemy is BaseEnemy):
		enemy.visible = enemy.stage_layer & type != 0
	Coins.visible = type & StageTypes.types.Coins != 0
	for floorOrWall in Walls.get_children().filter(func(wall): return wall is FloorOrWall):
		floorOrWall.visible = floorOrWall.stage_layer & type != 0
