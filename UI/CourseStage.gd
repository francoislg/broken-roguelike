@tool
extends Control

class_name CourseStage

@onready var StageNum = $"StageNum"
@onready var StageType = $"StageType"
@onready var Selected = $"Selected"

var typesMap = {
	StageTypes.types.AreaControl: 'Area Control',
	StageTypes.types.CaptureTheFlag: 'Bring Back Flags',
	StageTypes.types.Coins: 'Get Coins',
	StageTypes.types.Waves: 'Kill Cubes'
}

func _ready():
	if Engine.is_editor_hint():
		StageNum.set_text("1")
		StageType.set_text(typesMap[StageTypes.types.AreaControl])

func set_config(config: StageConfiguration):
	StageNum.set_text("Map #%s" % (config.index + 1))
	StageType.set_text(typesMap[config.type])

func set_selected(selected: bool):
	Selected.visible = selected
