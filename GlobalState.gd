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
	DOWNLOAD_SIZE,
	SPACE_LEFT,
	KEY_PRESSED_TEN_SECONDS,
	KEY_PRESSED_TIMER,
	# Time
	CLOCK_HOURS,
	CLOCK_MINUTES,
	CLOCK_SECONDS,
	DAY_OF_MONTH
};

var state = {}

var mainThread: Thread
var startTime: float
var keysPressedLastTenSeconds: Array
var keyPressedTimer: Timer

func _ready():
	for k in States.values():
		state[k] = 0
	
	startTime = Time.get_unix_time_from_system()
	
	keyPressedTimer = Timer.new()
	keyPressedTimer.connect('timeout', onKeyPressedTimerEnd)
	add_child(keyPressedTimer)
	
	mainThread = Thread.new()
	mainThread.start(threadedUpdate)

func threadedUpdate():
	oneShotUpdates()
	slowUpdates()
	fastUpdates()

	var fastTimer = Timer.new()
	add_child(fastTimer)
	fastTimer.wait_time = 1
	fastTimer.connect('timeout', fastUpdates)
	fastTimer.start()

	var slowTimer = Timer.new()
	add_child(slowTimer)
	slowTimer.wait_time = 10
	slowTimer.connect('timeout', slowUpdates)
	slowTimer.start()

func oneShotUpdates():
	updateTotalRam()
	updateDownloadSize()
	updateSpaceLeft()
	state[States.PROCESSOR_COUNT] = OS.get_processor_count()


func slowUpdates():
	state[States.SCREEN_REFRESH_RATE] = DisplayServer.screen_get_refresh_rate()
	return

func fastUpdates():
	var threads = multiple_threads([updateCpuUsage])

	updateClock()
	updateCurrentSession()
	updateKeyPressedTimer()
	state[States.FPS] = Engine.get_frames_per_second()

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
		state[States.TOTAL_RAM] = UnitConverter.convertBytesToGb(ramInBytes)

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
	
func updateDownloadSize():
	var downloadDir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	var totalSize = 0
	for file in downloadDir.get_files():
		var fileDir = downloadDir.get_current_dir(true) + "/" + file
		totalSize += FileAccess.open(fileDir, FileAccess.READ).get_length()
	state[States.DOWNLOAD_SIZE] = UnitConverter.convertBytesToGb(totalSize)

func updateSpaceLeft():
	var spaceLeft = DirAccess.open(OS.get_system_dir(0)).get_space_left()
	state[States.SPACE_LEFT] = UnitConverter.convertBytesToGb(spaceLeft)
	

func _input(_event):
	if (_event is InputEventKey and (_event as InputEventKey).pressed):
		if (keysPressedLastTenSeconds.size() == 0):
			keysPressedLastTenSeconds = [[_event,10]]
			keyPressedTimer.wait_time = 10
			keyPressedTimer.start()
		else:
			keysPressedLastTenSeconds += [[_event, keyPressedTimer.time_left]]
		state[States.KEY_PRESSED_TEN_SECONDS] = keysPressedLastTenSeconds.size()

func onKeyPressedTimerEnd():
	var lastKeyTimer = keysPressedLastTenSeconds[0][1]
	keysPressedLastTenSeconds.pop_front()
	state[States.KEY_PRESSED_TEN_SECONDS] = keysPressedLastTenSeconds.size()
	if (keysPressedLastTenSeconds.size() == 0):
		keyPressedTimer.stop()
	else:
		var currentKeyTimer = keysPressedLastTenSeconds[0][1]
		if (lastKeyTimer - currentKeyTimer > 0):
			keyPressedTimer.wait_time = lastKeyTimer - currentKeyTimer
			keyPressedTimer.start()
		else:
			onKeyPressedTimerEnd()
		

func updateKeyPressedTimer():
	state[States.KEY_PRESSED_TIMER] = "%2.2f" % keyPressedTimer.time_left

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
