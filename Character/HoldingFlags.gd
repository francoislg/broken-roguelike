extends Node

@onready var One := $One
@onready var Two := $Two
@onready var Three := $Three

var picked_up_flags: Array[Flag] = []

func _ready():
	set_number_of_flags(0)
	
func pick_up_flag(flag: Flag):
	if flag.pick_up():
		picked_up_flags.push_front(flag)
		set_number_of_flags(picked_up_flags.size())

func drop_all_flags():
	for flag in picked_up_flags:
		flag.reset()
	picked_up_flags = []
	set_number_of_flags(0)

func claim_flags():
	for flag in picked_up_flags:
		flag.claim()
	picked_up_flags = []
	set_number_of_flags(0)

func set_number_of_flags(flags: int):
	One.visible = flags >= 1
	Two.visible = flags >= 2
	Three.visible = flags >= 3
