extends BaseEnemy

@onready var ColoredRectangle := $ColoredRectangle

const BASE_SPEED = 0
const JUMP_SPEED = 800
# The higher this is, the faster the enemy will get to speed
const TIME_TO_GET_TO_SPEED = 5000
const DISTANCE_FOR_JUMP = 500

const TIME_TO_COOLDOWN = 0.5
const TIME_TO_COOLDOWN_WHEN_DAMAGED = 0.1
const MAX_JUMP_COUNT_WHEN_DAMAGED = 3

var gravity = 3000

enum Mode { Standing, Jumping, Landing, Damaged }

var mode := Mode.Standing
var onLandingTimer = Timer.new()
var directionJump := Vector2.ZERO
var isJumpingRight = true
var jumpCountOnDamaged = 0

func _ready():
	super()
	onLandingTimer.one_shot = true
	onLandingTimer.wait_time = 1
	onLandingTimer.connect("timeout", onLandingCooldownFinish)
	add_child(onLandingTimer)

func _process(_delta):
	var diff = character.position - position
	
	if is_on_floor() and mode == Mode.Jumping:
		landing()
		
	if mode == Mode.Standing and diff.length() <= DISTANCE_FOR_JUMP:
		jump()

func _physics_process(delta):
	var normalizedDiff = (character.position - position).normalized()
	
	match (mode):
		Mode.Damaged:
			velocity = velocity.move_toward(normalizedDiff * BASE_SPEED / 4, delta * TIME_TO_GET_TO_SPEED)
		Mode.Jumping:
			velocity = velocity.move_toward(normalizedDiff * directionJump * JUMP_SPEED, delta * TIME_TO_GET_TO_SPEED)
		Mode.Landing:
			velocity = velocity.move_toward(normalizedDiff * BASE_SPEED / 2, delta * TIME_TO_GET_TO_SPEED * 2)
		_: # Standing
			velocity = velocity.move_toward(Vector2.ZERO, delta * TIME_TO_GET_TO_SPEED * 4)
	
	move_and_collide(velocity * delta)
	

func jump():
	if (mode == Mode.Damaged):
		jumpCountOnDamaged += 1
		directionJump = (character.position - position).normalized()
		if (jumpCountOnDamaged > MAX_JUMP_COUNT_WHEN_DAMAGED):
			mode = Mode.Jumping
	else:
		ColoredRectangle.color = Color.RED
		directionJump = -(character.position - position).normalized()
		mode = Mode.Jumping

func landing():
	ColoredRectangle.color = Color.hex(0xba4fc2)
	if (mode == Mode.Jumping):
		onLandingTimer.wait_time = TIME_TO_COOLDOWN
	else:
		onLandingTimer.wait_time = 0.1
	onLandingTimer.start()
	
func onLandingCooldownFinish():
	mode = Mode.Standing
	
func receive_damage(direction: Vector2, damage: float):
	super(direction, damage)
	onLandingTimer.stop()
	ColoredRectangle.color = Color.WHITE
	mode = Mode.Damaged
	jump()
