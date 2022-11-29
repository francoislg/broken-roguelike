extends Node

enum States {
   CPU_USAGE,
   TOTAL_RAM,
DOWNLOAD_SIZE,
SPACE_LEFT
};

var state = {
	States.CPU_USAGE: 0,
	States.TOTAL_RAM: 0,
	States.DOWNLOAD_SIZE: 0,
	States.SPACE_LEFT: 0
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
	fastTimer.wait_time = 5
	fastTimer.connect('timeout', fastUpdates);
	fastTimer.start()

	var slowTimer = Timer.new()
	add_child(slowTimer)
	slowTimer.wait_time = 10
	slowTimer.connect('timeout', slowUpdates);
	slowTimer.start()

func oneShotUpdates():
	updateTotalRam()
	updateDownloadSize()
	updateSpaceLeft()

func slowUpdates():
	return

func fastUpdates():
	updateCpuUsage()

func updateCpuUsage():
	var result = wmicCall("cpu get loadpercentage")
	if result:
		state[States.CPU_USAGE] = result

func updateTotalRam():
	var ramInBytes = wmicCall("computersystem get totalphysicalmemory")
	if ramInBytes:
		state[States.TOTAL_RAM] = ramInBytes

# Could probably use one wmic call with "/value" to retrieve every PC information at once

func wmicCall(args: String):
	var output = []
	OS.execute("wmic", args.split(" "), output)
	return output[0].split(" ")[2].rstrip('\r\n').lstrip('\r\n')
	

func updateDownloadSize():
	var downloadDir = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	var totalSize = 0;
	for file in downloadDir.get_files():
		var fileDir = downloadDir.get_current_dir(true) + "/" + file
		totalSize += FileAccess.open(fileDir, FileAccess.READ).get_length()
	state[States.DOWNLOAD_SIZE] = UnitConverter.convertBytesToGb(totalSize);

func updateSpaceLeft():
	var spaceLeft = DirAccess.open(OS.get_system_dir(0)).get_space_left()
	state[States.SPACE_LEFT] = UnitConverter.convertBytesToGb(spaceLeft);
