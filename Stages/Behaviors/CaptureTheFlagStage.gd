extends Node

class_name CaptureTheFlagStage

signal stage_win

@onready var Flags := $"../../Flags"
@onready var FlagDestination := $"../../FlagDestination"
@onready var StageLabel := $"../../UI/StageLabel"

var numberOfFlags := 0

func do_ready():
	for flag in Flags.get_children().filter(func(c): return c is Flag):
		numberOfFlags += 1
		flag.connect("flag_claimed", on_flag_claimed)
	updateLabel()

func do_process(_delta):
	pass

func on_flag_claimed():
	numberOfFlags -= 1
	
	updateLabel()
	
	if numberOfFlags <= 0:
		emit_signal('stage_win')

func updateLabel():
	StageLabel.text = "Flags Left: %s" % numberOfFlags
