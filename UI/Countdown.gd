extends RichTextLabel

signal done

var reset_time: int = 3;
var seconds_to_display_go: int = 2;
var timer: Timer
var time: int = reset_time;

func _ready():
	timer = Timer.new()
	timer.connect('timeout', countdown)
	timer.wait_time = 1
	add_child(timer)

func reset():
	time = reset_time
	timer.start()
	visible = true
	
func countdown():
	time -= 1
	if time > 0:
		set_text("[center]%s[/center]" % time)
	elif time == 0:
		set_text("[center]GO![/center]")
		emit_signal("done")
	elif time < -seconds_to_display_go:
		visible = false
		timer.stop()
