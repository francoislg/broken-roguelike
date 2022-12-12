extends Node

class PlayerVariables:
	var meleeCooldown: float
	var meleeDamage: float
	var projectileCooldown: float
	var projectileDamage: float
	var movementSpeed: float
	var maximumSpeed: float
	var jumpHeight: float

var Effects := Combos.Effects;

const BASE_ATTACK_DAMAGE = 1
const BASE_ATTACK_COOLDOWN = 2
const BASE_PROJECTILE_DAMAGE = 1
const BASE_PROJECTILE_COOLDOWN = 2
const BASE_JUMP_FORCE = 700
const WALK_FORCE = 3200
const WALK_MAX_SPEED = 575

var combos: Array[Combos.Combo] = []

var playerVariables := PlayerVariables.new()

func _init():
	onStateUpdated()
	GlobalState.connect("state_updated", onStateUpdated)

func onStateUpdated():
	updateStatsFromCombo(playerVariables, combos)

func updateStatsFromCombo(variables: PlayerVariables, combos: Array[Combos.Combo]):
	var sums = Effects.values().reduce(func (sums, effect):
		sums[effect] = 0
		return sums
	, {});
	var sumPerEffect = combos.reduce(func (sums, combo): 
		sums[combo.effect] += GlobalState.ratioedState(combo.state)
		return sums
	, sums)
	
	variables.meleeCooldown = max(BASE_ATTACK_COOLDOWN - (BASE_ATTACK_COOLDOWN * sumPerEffect[Effects.MeleeCooldown]), 0.1)
	variables.meleeDamage = BASE_ATTACK_DAMAGE + (BASE_ATTACK_DAMAGE * sumPerEffect[Effects.MeleeDamage])
	variables.projectileDamage = BASE_PROJECTILE_DAMAGE + (BASE_PROJECTILE_DAMAGE * sumPerEffect[Effects.ProjectileDamage])
	variables.projectileCooldown = max(BASE_PROJECTILE_COOLDOWN - (BASE_PROJECTILE_COOLDOWN * sumPerEffect[Effects.ProjectileCooldown]), 0.1)
	variables.movementSpeed = WALK_FORCE + (WALK_FORCE * sumPerEffect[Effects.MovementSpeed])
	variables.maximumSpeed = WALK_MAX_SPEED + (WALK_MAX_SPEED * sumPerEffect[Effects.MovementSpeed])
	variables.jumpHeight = BASE_JUMP_FORCE + (BASE_JUMP_FORCE * sumPerEffect[Effects.JumpHeight])

func add_combo(combo: Combos.Combo):
	combos.push_front(combo)
	onStateUpdated()

func addRandomCombo():
	add_combo(Combos.getCombo())

func reset_combos():
	combos = []
	onStateUpdated()
