extends CharacterBody2D

class_name Player

signal player_hp(hp: int)
signal receive_damage()
signal received_damage_end()
signal reset_player()
signal on_hitting_enemy(enemy: BaseEnemy)

@onready var sprite := $AnimatedSprite2D

@onready var MeleeRange := $MeleeRange
@onready var CharacterStats := $CharacterStats
@onready var ProjectileSpawner := $ProjectileSpawner
@onready var HoldingFlags := $HoldingFlags
@onready var playerVariables = CharacterStats.playerVariables

const STOP_FORCE = 2000
const WALL_GRAVITY_MODIFIER = 0.25
const JUMP_BUTTON_GRAVITY_MODIFIER = 0.50
const RECEIVE_DAMAGE_KNOCKBACK_FORCE = 1200
const ENEMY_HIT_KNOCKBACK_FORCE = 700

var gravity = 3000 #ProjectSettings.get_setting("physics/2d/default_gravity")

var movement_stopped = false
var buffered_frames_jump = 0
var jump_touched_a_wall = false
var lastJumpTimer
var movementStoppedTimer := Timer.new() 
var receivedDamageFlashing = Timer.new() 
var receivedDamageEndTimer = Timer.new()
var fallAttackGraceTimer = Timer.new()
var justUsedFallAttack = false
var isOnDamageCooldown = false
var isVulnerable = false

var hp := 3

func _ready():
	add_child(Timers.initTimer(movementStoppedTimer, "movementStopped", 0.2, _on_timer_movement_stopped))
	add_child(Timers.initTimer(receivedDamageFlashing, "receivedDamageFlashing", 0.1, _on_receive_damage_timer))
	add_child(Timers.initOneShotTimer(fallAttackGraceTimer, "fallAttackGrace", 0.5, func(): justUsedFallAttack = false))
	add_child(Timers.initTimer(receivedDamageEndTimer, "receivedDamageEnd", 3, _on_receive_damage_end_timer))
	emit_signal('player_hp', hp)

func _physics_process(delta):
	if (Input.is_action_just_pressed("LEFT") || Input.is_action_just_pressed("RIGHT")) and is_on_floor():
		velocity.x = velocity.x / 2
	var walk = playerVariables.movementSpeed * (Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"))
	
	if movement_stopped:
		walk = 0
	
	if abs(walk) < playerVariables.movementSpeed * 0.2:
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	
	#Stops most of the momentum if you press the opposite direction of the current velocity for better air control
	if walk < 0:
		velocity.x = clamp(velocity.x, -playerVariables.maximumSpeed, playerVariables.maximumSpeed * 0.1)
	elif walk > 0:
		velocity.x = clamp(velocity.x, -playerVariables.maximumSpeed * 0.1, playerVariables.maximumSpeed)
	else:
		velocity.x = clamp(velocity.x, -playerVariables.maximumSpeed, playerVariables.maximumSpeed)
	
	var touchesRight = test_move(self.transform, Vector2(1, 0))
	var touchesLeft = test_move(self.transform, Vector2(-1, 0))
	var touchesAWall = touchesLeft || touchesRight
	
	if touchesAWall and !is_on_floor():
		jump_touched_a_wall = true
	else:
		jump_touched_a_wall = false
		
	if justUsedFallAttack and is_on_floor():
		justUsedFallAttack = false
	
	if (touchesLeft):
		velocity.x = clamp(velocity.x, 0, playerVariables.maximumSpeed)
	if (touchesRight):
		velocity.x = clamp(velocity.x, -playerVariables.maximumSpeed, 0)
	
	var isGoingUp = velocity.y < 0;
	
	var baseGravity = gravity * delta
	if not isGoingUp and touchesAWall and not movement_stopped and abs(walk) > 0:
		velocity.y = clamp(velocity.y + baseGravity * WALL_GRAVITY_MODIFIER, -playerVariables.jumpHeight * WALL_GRAVITY_MODIFIER, 10000)
	else:
		velocity.y += baseGravity * JUMP_BUTTON_GRAVITY_MODIFIER if isGoingUp and Input.is_action_pressed("JUMP") else baseGravity
	
	if not movement_stopped and Input.is_action_just_pressed("FALL"):
		velocity.y = playerVariables.jumpHeight
		justUsedFallAttack = true

	if not movement_stopped and Input.is_action_just_pressed("JUMP"):
		buffered_frames_jump = 0.1

	if (buffered_frames_jump > 0):
		if (is_on_floor() or touchesAWall):
			buffered_frames_jump = 0
			velocity.y = -playerVariables.jumpHeight
			if (touchesAWall and not is_on_floor()):
				stopMovementFor(0.2)
				movement_stopped = true
				if (touchesLeft):
					velocity.x = playerVariables.jumpHeight
				elif (touchesRight):
					velocity.x = -playerVariables.jumpHeight
		else:
			buffered_frames_jump -= delta;
	move_and_slide()
	
	if velocity.x != 0:
		sprite.set_flip_h(velocity.x < 0)
		
func reset():
	isVulnerable = true
	movement_stopped = false
	buffered_frames_jump = 0
	jump_touched_a_wall = false
	justUsedFallAttack = false
	_on_timer_movement_stopped()
	velocity = Vector2.ZERO
	visible = true
	ProjectileSpawner.reset()
	emit_signal("reset_player")

func stopMovementFor(time: float):
	movementStoppedTimer.wait_time = time
	movementStoppedTimer.start()
	movement_stopped = true

func _on_timer_movement_stopped():
	movement_stopped = false

func activate_fall_grace():
	fallAttackGraceTimer.start()

func _on_melee_range_body_entered(hit):
	if hit is Coin:
		hit.pick_up()
		
	if hit is Flag:
		HoldingFlags.pick_up_flag(hit)
		
	if hit is FlagDestination:
		HoldingFlags.claim_flags()
		
	if hit is Spring:
		on_spring()
		
	if hit is BaseEnemy:
		var playerHitDirection = (hit.position - position).normalized()
	
		velocity = -playerHitDirection * ENEMY_HIT_KNOCKBACK_FORCE
		if justUsedFallAttack:
			velocity.y *= 2

		stopMovementFor(0.2)
		if not isOnDamageCooldown:
			emit_signal("on_hitting_enemy", hit)
		
		if isVulnerable:
			on_receive_damage(playerHitDirection)

func on_receive_damage(hitDirection: Vector2):
	if not isOnDamageCooldown:
		isOnDamageCooldown = true

		var direction := Vector2.LEFT if hitDirection.x > 0 else Vector2.RIGHT
		velocity = (direction * RECEIVE_DAMAGE_KNOCKBACK_FORCE) + (Vector2.UP * RECEIVE_DAMAGE_KNOCKBACK_FORCE / 4)
		stopMovementFor(0.5)

		set_collision_layer_value(2, false)
		set_collision_mask_value(3, false)
		$MeleeRange.set_collision_layer_value(2, false)
		$MeleeRange.set_collision_mask_value(3, false)
		
		hp -= 1
		emit_signal('player_hp', hp)
		emit_signal('receive_damage')
		
		if hp > 0:
			stopMovementFor(0.5)
			receivedDamageEndTimer.start()
			HoldingFlags.drop_all_flags()
		else:
			stopMovementFor(2)

		receivedDamageFlashing.start()

func _on_receive_damage_timer():
	visible = !visible

func _on_receive_damage_end_timer():
	isOnDamageCooldown = false
	receivedDamageFlashing.stop()
	visible = true
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	$MeleeRange.set_collision_layer_value(2, true)
	$MeleeRange.set_collision_mask_value(3, true)
	emit_signal("received_damage_end")

func on_spring():
	velocity.y = -playerVariables.jumpHeight * 2

