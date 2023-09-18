extends Node

# For debug purposes
@export
var disable_countdown = false

@onready var Character := %Character
@onready var Stage := %Stage
@onready var Countdown := %Countdown

func _ready():
	var endDetected = false
	Stage.connect("stage_win", func():
		if not endDetected:
			endDetected = true
			Engine.time_scale = 0.2
			doAfter(0.8, func():
				Engine.time_scale = 1
				var tree = get_tree()
				tree.reload_current_scene()
			)
	)
	Character.connect("player_hit", func(hp):
		if not endDetected:
			endDetected = true
			if hp <= 0:
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
	if !disable_countdown:
		prepareStageStart()
	
func prepareStageStart():
	Countdown.connect("ready", func(): 
		Countdown.connect("done", func():
			var tree = get_tree()
			tree.paused = false
		)
		var tree = get_tree()
		tree.paused = true
		Countdown.reset();
	)

func doAfter(wait_time: float, do: Callable):
	var timer = Timer.new();
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.connect('timeout', do)
	add_child(timer)
