@tool
extends Node

class_name StageManager

signal stage_win

@export_group("Map")
@export_flags("Coins", "Waves", "CaptureTheFlag", "AreaControl") var supported_types = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag | StageTypes.types.AreaControl
@export var bounds: Vector2

@onready var Coins := $Coins
@onready var Flags := $Flags
@onready var FlagDestination := $FlagDestination
@onready var Areas := $Areas
@onready var Enemies := $Enemies
@onready var Props := $Props
@onready var Walls := $Walls
@onready var Character := $"/root/Scene/Character"
@onready var StartingPoint := $StartingPoint
@onready var UI := $UI
@onready var StagesBehaviors := {
	StageTypes.types.Coins: $Behaviors/CoinStage,
	StageTypes.types.Waves: $Behaviors/WavesStage,
	StageTypes.types.CaptureTheFlag: $Behaviors/CaptureTheFlagStage,
	StageTypes.types.AreaControl: $Behaviors/AreaControlStage
}
@onready var Bounds := {
	"Right": $"Bounds/Right".position.x,
	"Bottom": $"Bounds/Bottom".position.y,	
}

@export_group("Editor")
@export_flags("Coins", 'Waves', 'CaptureTheFlag', 'AreaControl') var editorType = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag | StageTypes.types.AreaControl:
	set(type):
		if type != editorType:
			editorType = type
			if Engine.is_editor_hint():
				set_visibility_for_stage_type(type)

var currentType: StageTypes.types = StageTypes.types.Coins
var currentBehavior

func _ready():
	UI.visible = false
	set_visibility_for_stage_type(StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag | StageTypes.types.AreaControl)

func get_supported_types():
	return [
		StageTypes.types.Coins if supported_types & StageTypes.types.Coins != 0 else 0,
		StageTypes.types.Waves if supported_types & StageTypes.types.Waves != 0 else 0,
		StageTypes.types.CaptureTheFlag if supported_types & StageTypes.types.CaptureTheFlag != 0 else 0,
		StageTypes.types.AreaControl if supported_types & StageTypes.types.AreaControl != 0 else 0,
	].filter(func(type): return type != 0)
	
func prepare_specific_stage(config: StageConfiguration):
	currentType = config.type
	currentBehavior = StagesBehaviors[currentType]
	set_up_stage()
	currentBehavior.do_ready()
	currentBehavior.connect('stage_win', on_stage_win)

func set_up_stage():
	UI.visible = true
	Character.position = StartingPoint.position
	
	for enemy in Enemies.get_children().filter(func(enemy): return enemy is BaseEnemy):
		if enemy.stage_layer & currentType == 0:
			Enemies.remove_child(enemy)
			
	for floorOrWall in Walls.get_children().filter(func(wall): return wall is FloorOrWall):
		if floorOrWall.stage_layer & currentType == 0:
			Walls.remove_child(floorOrWall)
	
	for prop in Props.get_children().filter(func(prop): return prop is Prop):
		if prop.stage_layer & currentType == 0:
			Props.remove_child(prop)

	if currentType & StageTypes.types.Coins == 0:
		remove_child(Coins)
	
	if currentType & StageTypes.types.CaptureTheFlag == 0:
		remove_child(Flags)
		remove_child(FlagDestination)
		
	if currentType & StageTypes.types.AreaControl == 0:
		remove_child(Areas)

func set_visibility_for_stage_type(type: int):
	Coins.visible = type & StageTypes.types.Coins != 0
	Flags.visible = type & StageTypes.types.CaptureTheFlag != 0
	Areas.visible = type & StageTypes.types.AreaControl != 0
	FlagDestination.visible = type & StageTypes.types.CaptureTheFlag != 0
	
	for enemy in Enemies.get_children().filter(func(enemy): return enemy is BaseEnemy):
		enemy.visible = enemy.stage_layer & type != 0
		
	for prop in Props.get_children().filter(func(prop): return prop is Prop):
		prop.visible = prop.stage_layer & type != 0
	
	for floorOrWall in Walls.get_children().filter(func(wall): return wall is FloorOrWall):
		floorOrWall.visible = floorOrWall.stage_layer & type != 0
		
func _process(delta):
	if not Engine.is_editor_hint():
		if currentBehavior:
			currentBehavior.do_process(delta)

func on_stage_win():
	UI.visible = false
	emit_signal('stage_win')
