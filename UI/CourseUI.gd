extends Control

@onready var StagesManager = %StagesManager
@onready var CourseStages: Array[CourseStage] = [$"CourseStage1", $"CourseStage2", $"CourseStage3", $"CourseStage4"]

func _ready():
	StagesManager.connect('new_current_stage_index', update_current_stage_index)
	StagesManager.connect("new_course", update_course)

func update_current_stage_index(stageIndex: int):
	for i in CourseStages.size():
		CourseStages[i].set_selected(stageIndex == i)
	queue_redraw()

func update_course(courseConfig: CourseConfiguration):
	for i in CourseStages.size():
		CourseStages[i].set_config(courseConfig.stages[i])
	queue_redraw()
