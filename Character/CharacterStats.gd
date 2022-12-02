extends Node

var Effects := Combos.Effects;

const BASE_ATTACK_DAMAGE = 1
const BASE_ATTACK_COOLDOWN = 2
const BASE_JUMP_FORCE = 700
const WALK_FORCE = 3200
const WALK_MAX_SPEED = 575

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
			return sum + GlobalState.ratioedState(combo.state)
		, 0)
		return max(BASE_ATTACK_COOLDOWN - (BASE_ATTACK_COOLDOWN * modifier), 0)

var meleeDamage:
	get:
		var modifier = combosPerEffects[Effects.MeleeDamage].reduce(func (sum, combo): 
			return sum + GlobalState.ratioedState(combo.state)
		, 0)
		return BASE_ATTACK_DAMAGE + (BASE_ATTACK_DAMAGE * modifier)

var movementSpeed:
	get:
		var modifier = combosPerEffects[Effects.MovementSpeed].reduce(func (sum, combo): 
			return sum + GlobalState.ratioedState(combo.state)
		, 0)
		return WALK_FORCE + (WALK_FORCE * modifier)
		
var maximumSpeed:
	get:
		var modifier = combosPerEffects[Effects.MovementSpeed].reduce(func (sum, combo): 
			return sum + GlobalState.ratioedState(combo.state)
		, 0)
		return WALK_MAX_SPEED + (WALK_MAX_SPEED * modifier)

var jumpHeight:
	get:
		var modifier = combosPerEffects[Effects.JumpHeight].reduce(func (sum, combo): 
			return sum + GlobalState.ratioedState(combo.state)
		, 0)
		return BASE_JUMP_FORCE + (BASE_JUMP_FORCE * modifier)

func addCombo():
	var combo = Combos.getCombo()
	combosPerEffects[combo.effect].push_front(combo)

