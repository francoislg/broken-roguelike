extends RichTextLabel

@onready var CharacterStats := $"../Character/CharacterStats"

var allStates = GlobalState.States.keys()
var allEffects = Combos.Effects.keys()

func _process(_delta):
	text = "Melee Cooldown: %s\nMelee Damage: %s\nMovement Speed: %s\nMaximum Speed: %s\nJump Height: %s\n Combos: %s" % [
			CharacterStats.meleeCooldown, 
			CharacterStats.meleeDamage, 
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
