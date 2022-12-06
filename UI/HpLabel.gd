extends Label

func _on_character_player_hit(hp):
	text = "HP: %s" % [hp]
