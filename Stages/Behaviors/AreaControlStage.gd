extends Node

class_name AreaControlStage

signal stage_win

@onready var Areas := $"../../Areas"

var count := 0

func do_ready():
	for area in Areas.get_children().filter(func(c): return c is Area):
		count += 1
		area.connect("area_finished", on_area_finished)
		

func do_process(_delta):
	pass

func on_area_finished():
	count -= 1
	if count <= 0:
		emit_signal('stage_win')
