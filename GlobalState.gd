extends Node

enum States {
	CPU_USAGE,
	TOTAL_RAM,
	CLOCK_HOURS,
	CLOCK_MINUTES,
	CLOCK_SECONDS,
	DAY_OF_MONTH
};

var state = {
	States.CPU_USAGE: 0,
	States.TOTAL_RAM: 0,
	States.CLOCK_HOURS: 0,
	States.CLOCK_MINUTES: 0,
	States.CLOCK_SECONDS: 0,
	States.DAY_OF_MONTH: 0,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var t = Thread.new()
	t.start(threadedUpdate)

func threadedUpdate():
	oneShotUpdates()
	slowUpdates()
	fastUpdates()

	var fastTimer = Timer.new()
	add_child(fastTimer)
	fastTimer.wait_time = 1
	fastTimer.connect('timeout', fastUpdates);
	fastTimer.start()

	var slowTimer = Timer.new()
	add_child(slowTimer)
	slowTimer.wait_time = 10
	slowTimer.connect('timeout', slowUpdates);
	slowTimer.start()

func oneShotUpdates():
	updateTotalRam()

func slowUpdates():
	return

func fastUpdates():
	var cpuUsageThread = Thread.new()
	cpuUsageThread.start(updateCpuUsage)
	updateClock()

func updateCpuUsage():
	var result = wmicCall("cpu get loadpercentage")
	if result:
		state[States.CPU_USAGE] = result

func updateTotalRam():
	var ramInBytes = wmicCall("computersystem get totalphysicalmemory")
	if ramInBytes:
		state[States.TOTAL_RAM] = float(ramInBytes) / 1024 / 1024 / 1024
		
func updateClock():
	var time = Time.get_datetime_dict_from_system()
	state[States.CLOCK_HOURS] = time.hour
	state[States.CLOCK_MINUTES] = time.minute
	state[States.CLOCK_SECONDS] = time.second
	state[States.DAY_OF_MONTH] = time.day

# Could probably use one wmic call with "/value" to retrieve every PC information at once

func wmicCall(args: String):
	var output = []
	OS.execute("wmic", args.split(" "), output)
	return output[0].split(" ")[2].rstrip('\r\n').lstrip('\r\n')
