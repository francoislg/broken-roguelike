extends Node

@onready var Character := $"../Character"

func _ready():
	Character.connect("player_hit", func(hp):
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

func doAfter(wait_time: float, do: Callable):
	var timer = Timer.new();
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.connect('timeout', do)
	add_child(timer)
