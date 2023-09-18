@tool
extends Control

class_name CourseStage

@onready var StageNum = $"StageNum"
@onready var StageType = $"StageType"
@onready var Selected = $"Selected"

var typesMap = {
	StageTypes.types.AreaControl: 'AreaControl',
	StageTypes.types.CaptureTheFlag: 'Flag',
	StageTypes.types.Coins: 'Coins',
	StageTypes.types.Waves: 'Waves'
}

func _ready():
	if Engine.is_editor_hint():
		StageNum.set_text("1")
		StageType.set_text(typesMap[StageTypes.types.AreaControl])

func set_config(config: StageConfiguration):
	StageNum.set_text("%s" % (config.index + 1))
	StageType.set_text(typesMap[config.type])

func set_selected(selected: bool):
	Selected.visible = selected
