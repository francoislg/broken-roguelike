extends Weapon

@onready var AttackDamageArea := $AttackDamageArea
@onready var Shield := $Shield

# A small margin in which the cooldown bar is displayed, but the attack is not active
# to ensure that the cooldown finishes a bit before the bar is full
const ATTACK_COOLDOWN_SMALL_MARGIN = 0.1
const TIME_TO_CONSIDER_STILL_ATTACKING = 0.3

var attackCooldownTimer := Timer.new() 
var isAttackingTimer = Timer.new()

var canAttack = true
var isAttacking = false

func _ready():
	add_child(Timers.initOneShotTimer(attackCooldownTimer, "attackCooldown", playerVariables.meleeCooldown, _on_timer_attackcooldown_stopped))
	add_child(Timers.initOneShotTimer(isAttackingTimer, "isAttacking", TIME_TO_CONSIDER_STILL_ATTACKING, _on_timer_is_attacking_end))
	Character.connect("receive_damage", on_receive_damage)
	Character.connect("reset_player", reset)
	Character.connect("on_hitting_enemy", on_hitting_enemy)
	
func _process(_delta):
	update_attackcooldown_bar()

func reset():
	canAttack = true
	isAttacking = false
	Character.isVulnerable = false
	Cooldown.reset()
	
func on_receive_damage():
	Cooldown.reset()

func on_hitting_enemy(_enemy: BaseEnemy):
	if canAttack:
		isAttacking = true
		isAttackingTimer.start()
		
		canAttack = false
		Cooldown.start(ATTACK_COOLDOWN_SMALL_MARGIN)
		attackCooldownTimer.wait_time = playerVariables.meleeCooldown - ATTACK_COOLDOWN_SMALL_MARGIN
		attackCooldownTimer.start()
		
		Shield.visible = true
		Shield.play()

		Character.activate_fall_grace()
		var hitEnemies = AttackDamageArea.get_overlapping_bodies().filter(func(body): return body is BaseEnemy)
		
		for enemy in hitEnemies:
			damage_enemy(enemy)

func _on_timer_is_attacking_end():
	isAttacking = false
	Character.isVulnerable = true

func _on_timer_attackcooldown_stopped():
	Cooldown.reset()
	canAttack = true
	Character.isVulnerable = false
	
func _on_attack_damage_area_body_entered(body):
	if isAttacking and body is BaseEnemy:
		damage_enemy(body)

func update_attackcooldown_bar():
	Cooldown.update_from_timer(attackCooldownTimer)

func damage_enemy(enemy: BaseEnemy):
	var enemyHitDirection = (enemy.position - Character.position).normalized()
	enemy.receive_damage(enemyHitDirection, playerVariables.meleeDamage)
