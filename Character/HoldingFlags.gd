extends Node

@onready var One := $One
@onready var Two := $Two
@onready var Three := $Three

func _ready():
	set_number_of_flags(0)

func set_number_of_flags(flags: int):
	One.visible = flags >= 1
	Two.visible = flags >= 2
	Three.visible = flags >= 3
