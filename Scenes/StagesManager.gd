extends Node

signal new_course(course: CourseConfiguration)
signal new_stage(stage: StageManager)
signal new_current_stage_index(currentStageIndex: int)

@export
var disable_countdown = false
var disable_start = disable_countdown

@onready var Stage := $"../"
@onready var Character := %Character
@onready var CharacterWeapons: Weapons = %"Character/Weapons"
@onready var CourseUI := %CourseUI
@onready var StageUI := %StageUI
@onready var ComboMenu := %ComboMenu
@onready var Countdown := %Countdown
@onready var Stages = $"../Stages"
@onready var PauseMenu = %StageUI/PauseMenu
var stages = [
	preload("res://Stages/Stage1.tscn"),
	preload("res://Stages/Stage2.tscn")
]
var stageInstances: Array[StageManager] = []

var course: CourseConfiguration
var currentStage: StageManager
var currentStageIndex = 0

var isPaused = false
var isInGame = false

func _ready():
	Countdown.connect("done", func():
		var tree = get_tree()
		tree.paused = false
		isInGame = true
	)
	reset_course()
	prepare_next_stage()
	start_stage_countdown()

func create_random_config():
	var stageIndex = randi_range(0, stages.size() - 1)
	var stage: StageManager = stages[stageIndex].instantiate()
	stageInstances.append(stage)
	var selectedStage: StageManager = stage
	var arrayOfSupportedTypes = selectedStage.get_supported_types()
	
	var config = StageConfiguration.new()
	config.type = arrayOfSupportedTypes[randi_range(0, arrayOfSupportedTypes.size() - 1)]
	config.index = stageIndex
	return config
	
func reset_course():
	finish_stage()
	currentStageIndex = 0
	stageInstances = []
	var courseConfig = CourseConfiguration.new()
	courseConfig.stages.append_array([
		create_random_config(),
		create_random_config(),
		create_random_config(),
		create_random_config(),
	])
	course = courseConfig
	emit_signal('new_course', courseConfig)

func prepare_next_stage(): 
	StageUI.visible = false
	CourseUI.visible = true

	var config = course.stages[currentStageIndex];
	currentStage = stageInstances[currentStageIndex]
	currentStage.connect("ready", func():
		Character.reset()
		CharacterWeapons.init_weapon_left(Weapons.WeaponTypes.Bullets)
		CharacterWeapons.init_weapon_right(Weapons.WeaponTypes.Bubble)
		currentStage.prepare_specific_stage(config)
		emit_signal("new_current_stage_index", currentStageIndex)
		emit_signal("new_stage", currentStage)
	)
	
	Stages.add_child(currentStage)
	
func start_stage_countdown():
	if disable_countdown:
		isInGame = true
		start_stage()
	else:
		var tree = get_tree()
		tree.paused = true
		doAfter(5, start_stage)

func start_stage():
	StageUI.visible = true
	CourseUI.visible = false
	
	var endDetected = false
	currentStage.connect("stage_win", func():
		if not endDetected:
			endDetected = true
			Engine.time_scale = 0.2
			doAfter(0.8, func():
				Engine.time_scale = 1
				currentStageIndex += 1

				if currentStageIndex >= stageInstances.size():
					disable_countdown = false
					reset_course()
				else:
					disable_countdown = true
					finish_stage()

				prepare_next_stage()
				show_combos()
			)
	)
	Character.connect("player_hp", func(hp):
		if not endDetected:
			endDetected = true
			if hp <= 0:
				isInGame = false
				var tree = get_tree()
				tree.paused = true
				
				doAfter(1, func():
					tree.paused = false
					Engine.time_scale = 0.2
					doAfter(0.8, func():
						Engine.time_scale = 1
						tree.reload_current_scene()
					)
				)
	)
	if !disable_start:
		get_tree().paused = true
		Countdown.reset();

func show_combos():
	get_tree().paused = true
	ComboMenu.new_combos()
	ComboMenu.show()
	ComboMenu.connect("combo_choice", after_combo_selection)
	
func after_combo_selection(_combo):
	ComboMenu.disconnect("combo_choice", after_combo_selection)
	start_stage();

func finish_stage():
	if currentStage:
		isInGame = false
		Stages.remove_child(currentStage)
		currentStage = null

func doAfter(wait_time: float, do: Callable):
	var timer = Timer.new();
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.connect('timeout', do)
	add_child(timer)

func _process(_f):
	if isInGame and Input.is_action_just_pressed("PAUSE"):
		isPaused = !isPaused
		PauseMenu.visible = isPaused
		get_tree().paused = isPaused
