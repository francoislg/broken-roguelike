extends Button

@onready var ComboMenu := $"../ComboMenu"
@onready var Character := $"../Character"

func _ready():
	ComboMenu.connect("combo_choice", on_combo_selected)

func _on_pressed():
	get_tree().paused = true
	ComboMenu.new_combos()
	ComboMenu.show()

func on_combo_selected(combo: Combos.Combo):
	get_tree().paused = false
	ComboMenu.hide()
	Character.CharacterStats.add_combo(combo)
