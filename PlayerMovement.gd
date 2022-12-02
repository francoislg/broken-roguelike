extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var attackDamageArea := $AttackDamageArea
@onready var attackCooldownBar = $AttackCooldownBar
@onready var CharacterStats := $CharacterStats
@onready var ProjectileSpawner := $ProjectileSpawner

const STOP_FORCE = 2000
const WALL_GRAVITY_MODIFIER = 0.25
const JUMP_BUTTON_GRAVITY_MODIFIER = 0.50
const ENEMY_HIT_KNOCKBACK_FORCE = 700
const ATTACK_COOLDOWN_HIT_KNOCKBACK_MODIFIER = 2.75

var gravity = 3000 #ProjectSettings.get_setting("physics/2d/default_gravity")

var movement_stopped = false
var buffered_frames_jump = 0
var jump_touched_a_wall = false
var lastJumpTimer := Timer.new()
var movementStoppedTimer := Timer.new()
var attackCooldownTimer := Timer.new()
var projectileTimer := Timer.new()
var canAttack = true

func _ready():
	movementStoppedTimer.wait_time = 0.2
	movementStoppedTimer.one_shot = true
	movementStoppedTimer.connect("timeout", _on_timer_movement_stopped)
	add_child(movementStoppedTimer)
	attackCooldownTimer.one_shot = true
	attackCooldownTimer.connect("timeout", _on_timer_attackcooldown_stopped)
	add_child(attackCooldownTimer)
	projectileTimer.wait_time = CharacterStats.projectileCooldown
	projectileTimer.connect("timeout", _on_timer_projectile)
	add_child(projectileTimer)
	projectileTimer.start()
	
	CharacterStats.addRandomCombo()
	CharacterStats.addRandomCombo()

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
	
	if Input.is_action_just_pressed("FALL"):
		velocity.y = CharacterStats.jumpHeight

	if (Input.is_action_just_pressed("JUMP")):
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

func _on_attack_range_area_body_entered(hit: PhysicsBody2D):
	var playerHitDirection = (hit.position - position).normalized()
	velocity = -playerHitDirection * ENEMY_HIT_KNOCKBACK_FORCE * (ATTACK_COOLDOWN_HIT_KNOCKBACK_MODIFIER if not canAttack else 1)
	stopMovementFor(0.2)
	
	var hasAttacked = false;
	
	if canAttack:
		var bodies = attackDamageArea.get_overlapping_bodies()
		for body in bodies:
			if body is BaseEnemy:
				var enemyHitDirection = (body.position - position).normalized()
				body.receive_damage(enemyHitDirection, CharacterStats.meleeDamage)
				hasAttacked = true
				
	if  hasAttacked:
		canAttack = false
		attackCooldownBar.show()
		attackCooldownTimer.wait_time = CharacterStats.meleeCooldown
		attackCooldownTimer.start()

