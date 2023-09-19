@tool
extends Node2D

@export var radius: float

@export var color: Color:
	set(value):
		_color = value
		queueRecolor = true
	get:
		return _color

var _color := Color.GREEN_YELLOW
var queueRecolor := true

func _process(_delta):
	if Engine.is_editor_hint() or queueRecolor:
		queue_redraw()
		queueRecolor = false

func _draw():
	draw_circle(position, radius, _color)
