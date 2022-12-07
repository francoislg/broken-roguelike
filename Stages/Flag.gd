extends Node2D

class_name Flag

signal flag_claimed

var isPickedUp: bool
var initialPosition: Vector2

func _ready():
	initialPosition = position

func pick_up():
	if not isPickedUp:
		isPickedUp = true
		visible = false
		return true
	return false

func drop_at(pos: Vector2):
	visible = true
	position = pos
	isPickedUp = false

func claim():
	emit_signal('flag_claimed')
	queue_free()

func reset():
	drop_at(initialPosition)

