extends RichTextLabel

var state = GlobalState.state

# Called when the node enters the scene tree for the first time.
func _ready():
	Time.get_datetime_dict_from_system()
	var processor_count = OS.get_processor_count()
	var processor_name = OS.get_processor_name()
	var video = OS.get_video_adapter_driver_info()
	var a = DisplayServer.screen_get_refresh_rate()
	#var rendering = FileAccess.open("a", FileAccess.READ).get_length()
	
	var output = [];
	var t = Thread.new()
	t.start(threadedUpdate)
	
	text = "Loaded"
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "Ram: %s, CPU Usage: %s" % [state.TOTAL_RAM, state.CPU_USAGE]
	
	pass
	

func threadedUpdate():
	updateTotalRam()
	poll()
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.connect('timeout', poll);
	timer.start()

func poll():
	updateCpuUsage()
	
func updateCpuUsage():
	var result = wmicCall("cpu get loadpercentage")
	if result:
		state.CPU_USAGE = result
	
func updateTotalRam():
	var ramInBytes = wmicCall("computersystem get totalphysicalmemory")
	if ramInBytes:
		state.TOTAL_RAM = float(ramInBytes) / 1024 / 1024 / 1024

# Could probably use one wmic call with "/value" to retrieve every PC information at once

func wmicCall(args: String):
	var output = []
	OS.execute("wmic", args.split(" "), output)
	return output[0].split(" ")[2].rstrip('\r\n').lstrip('\r\n')
