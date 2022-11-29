extends RichTextLabel

var state = GlobalState.state
var States = GlobalState.States

var allStates = States.keys()

# Called when the node enters the scene tree for the first time.
func _ready():
	Time.get_datetime_dict_from_system()
	var processor_count = OS.get_processor_count()
	var processor_name = OS.get_processor_name()
	var video = OS.get_video_adapter_driver_info()
	var a = DisplayServer.screen_get_refresh_rate()
	#var rendering = FileAccess.open("a", FileAccess.READ).get_length()
	
	text = "Loaded"
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = allStates.map(func (key):
		return "%s=%s" % [key, state[States[key]]]
	).reduce(func (acc, value):
		return "%s\n%s" % [acc, value]
	, "")
	
	pass
	
