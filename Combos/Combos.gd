extends Node

var States := GlobalState.States

enum Effects {
	MeleeCooldown,
	MeleeDamage,
	MeleeRadius,
	ProjectileSpeed,
	ProjectileDamage,
	MovementSpeed,
	JumpHeight,
	PlayerSize,
	HPRegen
}

class Combo:
	var state: GlobalState.States
	var effect: Effects
	var comboConfig: ComboConfig

	func _init(state: GlobalState.States, effect: Effects, comboConfig: ComboConfig):
		self.state = state
		self.effect = effect
		self.comboConfig = comboConfig;

class ComboConfig:
	var inverted = false

	func _init(inverted: bool):
		self.inverted = inverted


func getCombo() -> Combo:
	var states := States.values();
	var randomStateIndex := randi_range(0, states.size() - 1)
	
	var effects := [Effects.MeleeCooldown, Effects.MeleeDamage, Effects.MovementSpeed, Effects.JumpHeight];
	var randomEffectIndex := randi_range(0, effects.size() - 1)

	return Combo.new(states[randomStateIndex], effects[randomEffectIndex], ComboConfig.new(false))
