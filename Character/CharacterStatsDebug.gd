extends RichTextLabel

@onready var CharacterStats := $"../../Character/CharacterStats"

var allStates = GlobalState.States.keys()
var allEffects = Combos.Effects.keys()

func _process(_delta):
	text = "Melee CD/DMG: %s/%s\nProjectile CD/DMG: %s/%s\nMovement/Max Speed: %s/%s\nJump Height: %s\n-- Combos: --\n%s" % [
			CharacterStats.meleeCooldown,
			CharacterStats.meleeDamage,
			CharacterStats.projectileCooldown, 
			CharacterStats.projectileDamage, 
			CharacterStats.movementSpeed, 
			CharacterStats.maximumSpeed, 
			CharacterStats.jumpHeight,
			formatedCombos()
		]

func formatedCombos():
	return CharacterStats.combos.map(func (combo):
		return "%s/%s (%s%%)" % [allStates[combo.state], allEffects[combo.effect], GlobalState.ratioedState(combo.state) * 100]
	).reduce(func (acc, value):
		return "%s\n%s" % [acc, value]
	, "")
