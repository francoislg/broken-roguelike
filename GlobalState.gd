extends Node

enum States {
	# Game Stats
	SHORT_SESSION_GAMER,
	FPS,
	# Hardware
	CPU_USAGE,
	PROCESSOR_COUNT,
	TOTAL_RAM,
	SCREEN_REFRESH_RATE,
	# Time
	CLOCK_HOURS,
	CLOCK_MINUTES,
	CLOCK_SECONDS,
	DAY_OF_MONTH
};

var state = {}

var mainThread: Thread
var startTime: float

func _ready():
	for k in States.values():
		state[k] = 0
	
	startTime = Time.get_unix_time_from_system()
	
	mainThread = Thread.new()
	mainThread.start(threadedUpdate)

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
	state[States.PROCESSOR_COUNT] = OS.get_processor_count()

func slowUpdates():
	state[States.SCREEN_REFRESH_RATE] = DisplayServer.screen_get_refresh_rate()
	return

func fastUpdates():
	var threads = multiple_threads([updateCpuUsage])

	updateClock()
	updateCurrentSession()
	state[States.FPS] = Engine.get_frames_per_second();

	await dispose_threads(threads)

func updateCurrentSession():
	const timeInSecUntilKickoff = 60 * 5
	const timeInSecUntilZero = 60 * 30
	var timeSinceStart = Time.get_unix_time_from_system() - startTime
	state[States.SHORT_SESSION_GAMER] = clamp(lerpf(100, 0, (timeSinceStart - timeInSecUntilKickoff) / timeInSecUntilZero), 0, 100)

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
	
func multiple_threads(callables: Array[Callable]):
	return callables.map(func (callable):
		var thread = Thread.new()
		thread.start(callable)
		return thread
	)

func dispose_threads(threads: Array):
	while threads.any(func (t): t.is_alive()):
		await get_tree().process_frame
	for t in threads:
		while t.is_alive():
			await get_tree().process_frame
		t.wait_to_finish()
	
func _exit_tree():
	mainThread.wait_to_finish()
