extends StaticBody2D

class_name Coin

signal picked_up

func pick_up():
	emit_signal('picked_up')
	queue_free()
