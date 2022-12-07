extends CharacterBody2D

signal player_hit(hp: int)

@onready var sprite := $AnimatedSprite2D
@onready var attackDamageArea := $AttackDamageArea
@onready var attackCooldownBar = $AttackCooldownBar
@onready var CharacterStats := $CharacterStats
@onready var ProjectileSpawner := $ProjectileSpawner

const STOP_FORCE = 2000
const WALL_GRAVITY_MODIFIER = 0.25
const JUMP_BUTTON_GRAVITY_MODIFIER = 0.50
const ENEMY_HIT_KNOCKBACK_FORCE = 700
const RECEIVE_DAMAGE_KNOCKBACK_FORCE = 1200

var gravity = 3000 #ProjectSettings.get_setting("physics/2d/default_gravity")

var movement_stopped = false
var buffered_frames_jump = 0
var jump_touched_a_wall = false
var lastJumpTimer
var movementStoppedTimer := Timer.new() 
var attackCooldownTimer := Timer.new() 
var projectileTimer = Timer.new() 
var receivedDamageFlashing = Timer.new() 
var receivedDamageEndTimer = Timer.new() 
var canAttack = true
var isOnDamageCooldown = false

var hp := 3

func _ready():
	initTimer(movementStoppedTimer, 0.2, false, _on_timer_movement_stopped)
	initTimer(attackCooldownTimer, CharacterStats.meleeCooldown, true, _on_timer_attackcooldown_stopped)
	initTimer(projectileTimer, CharacterStats.projectileCooldown, false, _on_timer_projectile)
	initTimer(receivedDamageFlashing, 0.1, false, _on_receive_damage_timer)
	initTimer(receivedDamageEndTimer, 3, false, _on_receive_damage_end_timer)
	projectileTimer.start()
	emit_signal('player_hit', hp)

func _physics_process(delta):
	if (Input.is_action_just_pressed("LEFT") || Input.is_action_just_pressed("RIGHT")) and is_on_floor():
		velocity.x = velocity.x / 2
	var walk = CharacterStats.movementSpeed * (Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"))
	
	if movement_stopped:
		walk = 0
	
	if abs(walk) < CharacterStats.movementSpeed * 0.2:
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	
	#Stops most of the momentum if you press the opposite direction of the current velocity for better air control
	if walk < 0:
		velocity.x = clamp(velocity.x, -CharacterStats.maximumSpeed, CharacterStats.maximumSpeed * 0.1)
	elif walk > 0:
		velocity.x = clamp(velocity.x, -CharacterStats.maximumSpeed * 0.1, CharacterStats.maximumSpeed)
	else:
		velocity.x = clamp(velocity.x, -CharacterStats.maximumSpeed, CharacterStats.maximumSpeed)
	
	var touchesRight = test_move(self.transform, Vector2(1, 0))
	var touchesLeft = test_move(self.transform, Vector2(-1, 0))
	var touchesAWall = touchesLeft || touchesRight
	
	if touchesAWall and !is_on_floor():
		jump_touched_a_wall = true
	else:
		jump_touched_a_wall = false
	
	if (touchesLeft):
		velocity.x = clamp(velocity.x, 0, CharacterStats.maximumSpeed)
	if (touchesRight):
		velocity.x = clamp(velocity.x, -CharacterStats.maximumSpeed, 0)
	
	var isGoingUp = velocity.y < 0;
	
	var baseGravity = gravity * delta
	if (touchesAWall and not movement_stopped):
		velocity.y = clamp(velocity.y + baseGravity * WALL_GRAVITY_MODIFIER, -CharacterStats.jumpHeight * WALL_GRAVITY_MODIFIER, 10000)
	else:
		velocity.y += baseGravity * JUMP_BUTTON_GRAVITY_MODIFIER if isGoingUp and Input.is_action_pressed("JUMP") else baseGravity
	
	if not movement_stopped and Input.is_action_just_pressed("FALL"):
		velocity.y = CharacterStats.jumpHeight

	if not movement_stopped and Input.is_action_just_pressed("JUMP"):
		buffered_frames_jump = 0.1

	if (buffered_frames_jump > 0):
		if (is_on_floor() or touchesAWall):
			buffered_frames_jump = 0
			velocity.y = -CharacterStats.jumpHeight
			if (touchesAWall):
				stopMovementFor(0.2)
				movement_stopped = true
				if (touchesLeft):
					velocity.x = CharacterStats.jumpHeight
				elif (touchesRight):
					velocity.x = -CharacterStats.jumpHeight
		else:
			buffered_frames_jump -= delta;
	update_attackcooldown_bar()
	move_and_slide()
	
	if velocity.x != 0:
		sprite.set_flip_h(velocity.x < 0)

func stopMovementFor(time: float):
	movementStoppedTimer.wait_time = time
	movementStoppedTimer.start()
	movement_stopped = true

func _on_timer_movement_stopped():
	movement_stopped = false

func _on_timer_attackcooldown_stopped():
	attackCooldownBar.hide()
	canAttack = true
	
func _on_timer_projectile():
	ProjectileSpawner.create_projectile(position + (Vector2.UP * 10), (Vector2.LEFT if sprite.flip_h else Vector2.RIGHT) * 1000, CharacterStats.projectileDamage)
	projectileTimer.wait_time = CharacterStats.projectileCooldown

func update_attackcooldown_bar():
	var ratio = 1 - (attackCooldownTimer.time_left / attackCooldownTimer.wait_time)
	attackCooldownBar.value = ratio * 100

func _on_attack_range_area_body_entered(hit):
	if hit is Coin:
		hit.queue_free()
	
	if not isOnDamageCooldown:
		var enemies = attackDamageArea.get_overlapping_bodies().filter(func(body): return body is BaseEnemy)
		
		if enemies.size() > 0:
			var playerHitDirection = (hit.position - position).normalized()
			if canAttack:
				canAttack = false
				attackCooldownBar.show()
				attackCooldownTimer.wait_time = CharacterStats.meleeCooldown
				attackCooldownTimer.start()
				
				velocity = -playerHitDirection * ENEMY_HIT_KNOCKBACK_FORCE
				stopMovementFor(0.2)
				
				for enemy in enemies:
					var enemyHitDirection = (enemy.position - position).normalized()
					enemy.receive_damage(enemyHitDirection, CharacterStats.meleeDamage)
			else:
				on_receive_damage(playerHitDirection)

func on_receive_damage(hitDirection: Vector2):
	isOnDamageCooldown = true

	var direction := Vector2.LEFT if hitDirection.x > 0 else Vector2.RIGHT
	velocity = (direction * RECEIVE_DAMAGE_KNOCKBACK_FORCE) + (Vector2.UP * RECEIVE_DAMAGE_KNOCKBACK_FORCE / 4)
	stopMovementFor(0.5)

	set_collision_layer_value(2, false)
	set_collision_mask_value(3, false)
	
	hp -= 1
	emit_signal('player_hit', hp)
	
	if hp > 0:
		stopMovementFor(0.5)
		receivedDamageEndTimer.start()
	else:
		attackCooldownBar.hide()
		stopMovementFor(2)


	receivedDamageFlashing.start()
	projectileTimer.stop()

func _on_receive_damage_timer():
	visible = !visible

func _on_receive_damage_end_timer():
	isOnDamageCooldown = false
	receivedDamageFlashing.stop()
	visible = true
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	_on_timer_projectile()
	projectileTimer.start()

func initTimer(newTimer: Timer, waitTime: float, isOneShot: bool, onTimerEndFunction: Callable):
	add_child(newTimer)
	newTimer.wait_time = waitTime
	newTimer.one_shot = isOneShot
	newTimer.connect("timeout", onTimerEndFunction)
