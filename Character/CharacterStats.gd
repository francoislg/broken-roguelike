extends Node

class PlayerStats:
	var Effects := Combos.Effects;
	
	var meleeStr: float = 1
	var meleeSpd: float = 1
	var projectileStr: float = 1
	var projectileSpd: float = 1
	var agiMovement: float = 1
	var agiJump: float = 1
	
	func updateFromCombos(combos: Array[Combos.Combo]):
		var sums = Effects.values().reduce(func (sums, effect):
			sums[effect] = 0
			return sums
		, {});

		var sumPerEffect = combos.reduce(func (sums, combo): 
			sums[combo.effect] += GlobalState.ratioedState(combo.state)
			return sums
		, sums)
		
		self.meleeStr = 1 + sumPerEffect[Effects.MeleeStrength]
		self.meleeSpd = 1 + sumPerEffect[Effects.MeleeSpeed]
		self.projectileStr = 1 + sumPerEffect[Effects.ProjectileStrength]
		self.projectileSpd = 1 + sumPerEffect[Effects.ProjectileSpeed]
		self.agiMovement = 1 + sumPerEffect[Effects.AgilityMovement]
		self.agiJump = 1 + sumPerEffect[Effects.AgilityJump]
		

class PlayerVariables:
	const BASE_ATTACK_DAMAGE = 1
	const BASE_ATTACK_COOLDOWN = 2
	const BASE_PROJECTILE_DAMAGE = 1
	const BASE_PROJECTILE_COOLDOWN = 2
	const BASE_JUMP_FORCE = 700
	const WALK_FORCE = 3200
	const WALK_MAX_SPEED = 575
	
	var meleeCooldown: float
	var meleeDamage: float
	var projectileCooldown: float
	var projectileDamage: float
	var movementSpeed: float
	var maximumSpeed: float
	var jumpHeight: float
	
	func updateFromStats(stats: PlayerStats):
		self.meleeDamage = BASE_ATTACK_DAMAGE + remap(stats.meleeStr, 1, 5, 0, BASE_ATTACK_DAMAGE)
		self.meleeCooldown = max(BASE_ATTACK_COOLDOWN - remap(stats.meleeSpd, 1, 5, 0, BASE_ATTACK_COOLDOWN), 0.1)
		self.projectileDamage = BASE_PROJECTILE_DAMAGE + remap(stats.projectileStr, 1, 5, 0, BASE_PROJECTILE_DAMAGE)
		self.projectileCooldown = max(BASE_PROJECTILE_COOLDOWN - remap(stats.projectileSpd, 1, 5, 0, BASE_PROJECTILE_COOLDOWN), 0.1)
		self.movementSpeed = WALK_FORCE + remap(stats.agiMovement, 1, 5, 0, WALK_FORCE)
		self.maximumSpeed = WALK_MAX_SPEED + remap(stats.agiMovement, 1, 5, 0, WALK_MAX_SPEED)
		self.jumpHeight = BASE_JUMP_FORCE + remap(stats.agiMovement, 1, 5, 0, BASE_JUMP_FORCE)

var combos: Array[Combos.Combo] = []

var playerVariables := PlayerVariables.new()
var playerStats := PlayerStats.new()

func _init():
	onStateUpdated()
	GlobalState.connect("state_updated", onStateUpdated)

func onStateUpdated():
	playerStats.updateFromCombos(combos)
	playerVariables.updateFromStats(playerStats)

func add_combo(combo: Combos.Combo):
	combos.push_front(combo)
	onStateUpdated()

func addRandomCombo():
	add_combo(Combos.getCombo())

func reset_combos():
	combos = []
	onStateUpdated()
