extends Node

var States := GlobalState.States

enum Effects {
	MeleeCooldown,
	MeleeDamage,
	MeleeRadius,
	ProjectileCooldown,
	ProjectileDamage,
	MovementSpeed,
	JumpHeight,
	PlayerSize,
	HPRegen
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
	
	var effects := [Effects.MeleeCooldown, Effects.MeleeDamage, Effects.ProjectileCooldown,
		Effects.ProjectileDamage, Effects.MovementSpeed, Effects.JumpHeight];
	var randomEffectIndex := randi_range(0, effects.size() - 1)

	return Combo.new(states[randomStateIndex], effects[randomEffectIndex], ComboConfig.new(false))
