extends Node

signal state_updated

enum States {
	# Game Stats
	ELAPSED_TIME,
	FPS,
	WINDOW_PIXELS,
	# Hardware
	CPU_USAGE,
	PROCESSOR_COUNT,
	TOTAL_RAM,
	SCREEN_REFRESH_RATE,
	DOWNLOAD_SIZE,
	SPACE_LEFT,
	KEY_PRESSED_TEN_SECONDS,
	NUMBER_OF_DRIVES,
	NUMBER_OF_CONTROLLERS,
	# Time
	CLOCK_HOURS,
	CLOCK_MINUTES,
	CLOCK_SECONDS,
	DAY_OF_MONTH,
	INTERNET_SPEED
};

var state := {}

var stateKeys = States.keys()

var mainThread: Thread
var startTime: float
var lastKeyPressedHistoryIndex: int = 0
# If you adjust this, remember to adjust keyPressedTimer.wait_time. size 20 at 0.5 == 10 seconds
var keyPressedHistory := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var keyPressedTimer: Timer
var httpClient: HTTPClient;

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for k in States.values():
		state[k] = 0
	
	httpClient = HTTPClient.new()
	startTime = Time.get_unix_time_from_system()
	
	keyPressedTimer = Timer.new()
	add_child(keyPressedTimer)
	keyPressedTimer.wait_time = 0.5
	keyPressedTimer.connect('timeout', onKeyPressedTimerEnd)
	keyPressedTimer.start()
	
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
	
	emit_signal('state_updated')


func slowUpdates():
	var threads = multiple_threads([updateInternetSpeed])
	
	state[States.SCREEN_REFRESH_RATE] = DisplayServer.screen_get_refresh_rate()
	state[States.NUMBER_OF_DRIVES] = DirAccess.get_drive_count()
	state[States.NUMBER_OF_CONTROLLERS] = Input.get_connected_joypads().size()
	updateWindowPixels()
	
	await dispose_threads(threads)
	
	emit_signal('state_updated')

func fastUpdates():
	var threads = multiple_threads([updateCpuUsage])

	updateClock()
	state[States.FPS] = Engine.get_frames_per_second()
	state[States.ELAPSED_TIME] = round(Time.get_unix_time_from_system() - startTime)

	await dispose_threads(threads)
	
	emit_signal('state_updated')

func updateWindowPixels():
	var size = DisplayServer.window_get_max_size();
	state[States.WINDOW_PIXELS] = size.x * size.y;
	
func updateInternetSpeed():
	var requestStartTime = Time.get_unix_time_from_system()
	var err = httpClient.connect_to_host("www.google.com", 80)
	assert(err == OK)
	
	while httpClient.get_status() == HTTPClient.STATUS_CONNECTING or httpClient.get_status() == HTTPClient.STATUS_RESOLVING:
		httpClient.poll()
		await get_tree().process_frame
	
	var timeSinceRequest = Time.get_unix_time_from_system() - requestStartTime
	state[States.INTERNET_SPEED] = timeSinceRequest

func updateCpuUsage():
	var result = wmicCall("cpu get loadpercentage")
	if result:
		state[States.CPU_USAGE] = float(result)

func updateTotalRam():
	var ramInBytes = wmicCall("computersystem get totalphysicalmemory")
	if ramInBytes:
		state[States.TOTAL_RAM] = UnitConverter.convertBytesToGb(float(ramInBytes))

func updateClock():
	var time = Time.get_datetime_dict_from_system()
	state[States.CLOCK_HOURS] = time.hour
	state[States.CLOCK_MINUTES] = time.minute
	state[States.CLOCK_SECONDS] = time.second
	state[States.DAY_OF_MONTH] = time.day
	
# Battery: wmic path Win32_Battery get EstimatedChargeRemaining

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

func _input(event):
	if (event is InputEventKey and event.pressed and not event.echo):
		state[States.KEY_PRESSED_TEN_SECONDS] += 1
		keyPressedHistory[lastKeyPressedHistoryIndex] += 1
		

func onKeyPressedTimerEnd():
	var newKeypressIndex = (lastKeyPressedHistoryIndex + 1) % keyPressedHistory.size()
	state[States.KEY_PRESSED_TEN_SECONDS] -= keyPressedHistory[newKeypressIndex]
	keyPressedHistory[newKeypressIndex] = 0
	lastKeyPressedHistoryIndex = newKeypressIndex

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

# This must return 0 to 1 values
func ratioedState(key: States) -> float:
	var value = float(state[key])
	match(key):
		States.ELAPSED_TIME:
			const timeInSecUntilKickoff = 60 * 5
			const timeInSecUntilZero = 60 * 30
			return clamp(lerpf(1, 0, (value - timeInSecUntilKickoff) / timeInSecUntilZero), 0, 1)
		States.NUMBER_OF_DRIVES:
			return value * 10 / 100
		States.WINDOW_PIXELS:
			# We use log (which is the ln() math equivalent) to flatten the difference between 4k and the low resolution
			# (640 x 480) / (3840 x 2160) == 44% -> ln(2560 x 1440) / ln(3840 x 2160) = 94% 
			# (640 x 480) / (3840 x 2160) == 3.7% -> ln(640 x 480) / ln(3840 x 2160) = 80%
			# So, roughly, 4k gives ~0% bonus, 1440p gives ~25% bonus, 800x600 gives ~85%
			return remap(log(value), log(640 * 480), log(3840 * 2160), 1, 0)
		States.INTERNET_SPEED:
			return clamp(remap(value, 0, 3, 0, 1), 0, 100)
		_:
			return value / 100
