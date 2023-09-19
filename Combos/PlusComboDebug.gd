extends Button

@onready var ComboMenu := %ComboMenu
@onready var Character := %Character

func _ready():
	ComboMenu.connect("combo_choice", on_combo_selected)

func _on_pressed():
	ComboMenu.new_combos()
	ComboMenu.show()

func on_combo_selected(combo: Combos.Combo):
	ComboMenu.hide()
	Character.CharacterStats.add_combo(combo)
