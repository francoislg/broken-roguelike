extends Node

var Effects := Combos.Effects;

const BASE_ATTACK_DAMAGE = 1
const BASE_ATTACK_COOLDOWN = 2
const BASE_PROJECTILE_DAMAGE = 1
const BASE_PROJECTILE_COOLDOWN = 2
const BASE_JUMP_FORCE = 700
const WALK_FORCE = 3200
const WALK_MAX_SPEED = 575

var combos: Array[Combos.Combo] = []
var meleeCooldown: float
var meleeDamage: float
var projectileCooldown: float
var projectileDamage: float
var movementSpeed: float
var maximumSpeed: float
var jumpHeight: float

func _init():
	onStateUpdated()
	GlobalState.connect("state_updated", onStateUpdated)

func onStateUpdated():
	var sums = Effects.values().reduce(func (sums, effect):
		sums[effect] = 0
		return sums
	, {});
	var sumPerEffect = combos.reduce(func (sums, combo): 
		sums[combo.effect] += GlobalState.ratioedState(combo.state)
		return sums
	, sums)
	
	meleeCooldown = max(BASE_ATTACK_COOLDOWN - (BASE_ATTACK_COOLDOWN * sumPerEffect[Effects.MeleeCooldown]), 0)
	meleeDamage = BASE_ATTACK_DAMAGE + (BASE_ATTACK_DAMAGE * sumPerEffect[Effects.MeleeDamage])
	projectileDamage = BASE_PROJECTILE_DAMAGE + (BASE_PROJECTILE_DAMAGE * sumPerEffect[Effects.ProjectileDamage])
	projectileCooldown = max(BASE_PROJECTILE_COOLDOWN - (BASE_PROJECTILE_COOLDOWN * sumPerEffect[Effects.ProjectileCooldown]), 0)
	movementSpeed = WALK_FORCE + (WALK_FORCE * sumPerEffect[Effects.MovementSpeed])
	maximumSpeed = WALK_MAX_SPEED + (WALK_MAX_SPEED * sumPerEffect[Effects.MovementSpeed])
	jumpHeight = BASE_JUMP_FORCE + (BASE_JUMP_FORCE * sumPerEffect[Effects.JumpHeight])

func addRandomCombo():
	combos.push_front(Combos.getCombo())

