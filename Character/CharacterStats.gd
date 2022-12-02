extends Node

var Effects := Combos.Effects;

var BASE_ATTACK_COOLDOWN = 2

var combosPerEffects := {
	Effects.MeleeCooldown: [],
	Effects.MeleeDamage: [],
	Effects.MeleeRadius: [],
	Effects.ProjectileSpeed: [],
	Effects.ProjectileDamage: [],
	Effects.MovementSpeed: [],
	Effects.JumpHeight: [],
	Effects.PlayerSize: [],
	Effects.HPRegen: [],
}

var meleeCooldown:
	get:
		var modifier = combosPerEffects[Effects.MeleeCooldown].reduce(func (sum, combo): 
			return sum * (1 - GlobalState.ratioedState(combo.state))
		, 1)
		return max(BASE_ATTACK_COOLDOWN * modifier, 0)

var meleeDamage:
	get:
		return 1 + combosPerEffects[Effects.MeleeDamage].reduce(func (sum, combo): 
			return sum * GlobalState.ratioedState(combo.state)
		, 1)

func addCombo():
	var combo = Combos.getCombo()
	combosPerEffects[combo.effect].push_front(combo)
