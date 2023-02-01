extends AnimatedSprite2D

func _on_animation_finished():
	frame = 0
	visible = false
	stop()
