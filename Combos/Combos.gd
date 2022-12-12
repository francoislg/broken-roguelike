extends Node

var States := GlobalState.States

enum Effects {
	MeleeStrength,
	MeleeSpeed,
	ProjectileStrength,
	ProjectileSpeed,
	AgilityMovement,
	AgilityJump
}

var effectKeys = Effects.keys()

class Combo:
	var state: GlobalState.States
	var effect: Effects
	var comboConfig: ComboConfig

	func _init(_state: GlobalState.States, _effect: Effects, _comboConfig: ComboConfig):
		self.state = _state
		self.effect = _effect
		self.comboConfig = _comboConfig;

class ComboConfig:
	var inverted = false

	func _init(_inverted: bool):
		self.inverted = _inverted


func getCombo() -> Combo:
	var states := States.values();
	var randomStateIndex := randi_range(0, states.size() - 1)
	
	var effects := [Effects.MeleeStrength, Effects.MeleeSpeed, Effects.ProjectileStrength,
		Effects.ProjectileSpeed, Effects.AgilityMovement, Effects.AgilityJump];
	var randomEffectIndex := randi_range(0, effects.size() - 1)

	return Combo.new(states[randomStateIndex], effects[randomEffectIndex], ComboConfig.new(false))
