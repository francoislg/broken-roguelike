extends RichTextLabel

var state = GlobalState.state
var States = GlobalState.States

var allStates = States.keys()

func _ready():
	text = "Loaded"
	
	pass # Replace with function body.

func _process(_delta):
	text = allStates.map(func (key):
		return "%s=%s" % [key, state[States[key]]]
	).reduce(func (acc, value):
		return "%s\n%s" % [acc, value]
	, "")
	
	pass
	
