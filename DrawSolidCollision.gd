@tool
extends CollisionShape2D

@export var color := Color.WHITE:
	set(value):
		_color = value
		queueRecolor = true
	get:
		return _color

var _color := Color.WHITE
var queueRecolor := true

func _process(_delta):
	if Engine.is_editor_hint() or queueRecolor:
		queue_redraw()
		queueRecolor = false

func _draw():
	var ext:Vector2 = shape.extents
	var rect:Rect2 = Rect2(Vector2(-ext.x, -ext.y), ext*2)
	draw_rect(rect, _color, true)
