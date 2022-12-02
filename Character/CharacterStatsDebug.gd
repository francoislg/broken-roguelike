extends RichTextLabel

@onready var CharacterStats := $"../Character/CharacterStats"

var allStates = GlobalState.States.keys()
var allEffects = Combos.Effects.keys()

func _process(_delta):
	text = "Melee Cooldown: %s\nMelee Damage: %s\nCombos: %s" % [CharacterStats.meleeCooldown, CharacterStats.meleeDamage, formatedCombos()]

func formatedCombos():
	var allCombos = CharacterStats.combosPerEffects.values().reduce(func (all, comboList):
		for combo in comboList:
			all.push_front(combo)
		return all
	, []);
	return allCombos.map(func (combo):
		return "%s/%s" % [allStates[combo.state], allEffects[combo.effect]]
	).reduce(func (acc, value):
		return "%s\n%s" % [acc, value]
	, "")
