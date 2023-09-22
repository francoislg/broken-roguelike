extends ProgressBar

class_name CooldownUI

var buffer: float = 0

func _ready():
	hide()

func reset():
	hide()
	
func start(timeBuffer: float):
	show()
	buffer = timeBuffer

func update_from_timer(timer: Timer):
	update(timer.wait_time, timer.time_left)

func update(wait_time: float, time_left: float):
	var pct = 1 - (time_left / wait_time + buffer)
	value = pct * 100
