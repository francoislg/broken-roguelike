@tool
extends Node

signal stage_win

@export_flags("Coins", "Waves", "CaptureTheFlag") var supported_types = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag

@onready var Coins := $Coins
@onready var Flags := $Flags
@onready var FlagDestination := $FlagDestination
@onready var Enemies := $Enemies
@onready var Walls := $Walls
@onready var Character := %Character
@onready var StartingPoint := $StartingPoint
@onready var StagesBehaviors := {
	StageTypes.types.Coins: $Behaviors/CoinStage,
	StageTypes.types.Waves: $Behaviors/WavesStage,
	StageTypes.types.CaptureTheFlag: $Behaviors/CaptureTheFlagStage
}

@export_flags("Coins", 'Waves', 'CaptureTheFlag') var editorType = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag:
	set(type):
		if type != editorType:
			editorType = type
			if Engine.is_editor_hint():
				set_visibility_for_stage_type(type)

var currentType: StageTypes.types = StageTypes.types.Coins
var currentBehavior

func _ready():
	set_visibility_for_stage_type(StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag)
	
	if Engine.is_editor_hint():
		return
	
	var arrayOfSupportedTypes = [
		StageTypes.types.Coins if supported_types & StageTypes.types.Coins != 0 else 0,
		StageTypes.types.Waves if supported_types & StageTypes.types.Waves != 0 else 0,
		StageTypes.types.CaptureTheFlag if supported_types & StageTypes.types.CaptureTheFlag != 0 else 0,
	].filter(func(type): return type != 0)
	
	currentType = arrayOfSupportedTypes[randi_range(0, arrayOfSupportedTypes.size() - 1)]
	currentBehavior = StagesBehaviors[currentType]
	set_up_stage()
	currentBehavior.do_ready()
	currentBehavior.connect('stage_win', func(): emit_signal('stage_win'))
	
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
	
	if currentType & StageTypes.types.CaptureTheFlag == 0:
		remove_child(Flags)
		remove_child(FlagDestination)

func set_visibility_for_stage_type(type: StageTypes.types):
	for enemy in Enemies.get_children().filter(func(enemy): return enemy is BaseEnemy):
		enemy.visible = enemy.stage_layer & type != 0
	Coins.visible = type & StageTypes.types.Coins != 0
	Flags.visible = type & StageTypes.types.CaptureTheFlag != 0
	FlagDestination.visible = type & StageTypes.types.CaptureTheFlag != 0
	for floorOrWall in Walls.get_children().filter(func(wall): return wall is FloorOrWall):
		floorOrWall.visible = floorOrWall.stage_layer & type != 0
		
func _process(delta):
	if not Engine.is_editor_hint():
		currentBehavior.do_process(delta)
