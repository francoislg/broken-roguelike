extends Button

@onready var Character := $"../../Character"

func _on_pressed():
	Character.CharacterStats.reset_combos()
