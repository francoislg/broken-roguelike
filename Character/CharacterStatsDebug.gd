extends RichTextLabel

@onready var Character := %Character

@onready var playerVariables = Character.CharacterStats.playerVariables

var allStates = GlobalState.States.keys()
var allEffects = Combos.Effects.keys()

func _process(_delta):
	text = "Melee CD/DMG: %.2f/%.2f\nProjectile CD/DMG: %.2f/%.2f\nMovement/Max Speed: %.2f/%.2f\nJump Height: %.2f\n-- Combos: --\n%s" % [
			playerVariables.meleeCooldown,
			playerVariables.meleeDamage,
			playerVariables.projectileCooldown, 
			playerVariables.projectileDamage, 
			playerVariables.movementSpeed, 
			playerVariables.maximumSpeed, 
			playerVariables.jumpHeight,
			formatedCombos()
		]

func formatedCombos():
	return Character.CharacterStats.combos.map(func (combo):
		return "%s/%s (%.2f%%)" % [allStates[combo.state], allEffects[combo.effect], GlobalState.ratioedState(combo.state) * 100]
	).reduce(func (acc, value):
		return "%s\n%s" % [acc, value]
	, "")
