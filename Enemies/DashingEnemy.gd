extends BaseEnemy

@onready var ColoredRectangle := $ColoredRectangle

const BASE_SPEED = 400
const DASH_SPEED = 2000
const PREPARING_SPEED = 200
# The higher this is, the faster the enemy will get to speed
const TIME_TO_GET_TO_SPEED = 1400
const DISTANCE_FOR_DASH = 100

const TIME_TO_PREPARE = 1
const TIME_TO_DASH = 0.25
const TIME_TO_COOLDOWN = 1

enum Mode { Following, PreparingDash, Dashing, Standby }

var mode := Mode.Following
var modeTimer = Timer.new()
var preparingPosition := Vector2.ZERO
var directionDash := Vector2.ZERO

func _ready():
	super()
	modeTimer.one_shot = true
	modeTimer.wait_time = 1
	modeTimer.connect("timeout", nextMode)
	add_child(modeTimer)

func _process(delta):
	var diff = character.position - position
	
	if mode == Mode.Following and diff.length() <= DISTANCE_FOR_DASH:
		prepare_dash()

func _physics_process(delta):
	var diff = character.position - position
	
	if mode == Mode.Following:
		velocity = velocity.move_toward(diff.normalized() * BASE_SPEED, delta * TIME_TO_GET_TO_SPEED)
	elif mode == Mode.PreparingDash:
		velocity = velocity.move_toward(Vector2.ZERO, delta * TIME_TO_GET_TO_SPEED)
	elif mode == Mode.Dashing:
		velocity = velocity.move_toward(directionDash * DASH_SPEED, delta * TIME_TO_GET_TO_SPEED * 4)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * TIME_TO_GET_TO_SPEED * 4)
	
	move_and_collide(velocity * delta)


	
func nextMode():
	if mode == Mode.PreparingDash:
		finish_prepare_dash()
		modeTimer.wait_time = TIME_TO_DASH
		modeTimer.start()
	elif mode == Mode.Dashing:
		finish_dash()
		modeTimer.wait_time = TIME_TO_COOLDOWN
		modeTimer.start()
	elif mode == Mode.Standby:
		finish_standby()
		modeTimer.wait_time = TIME_TO_COOLDOWN
		modeTimer.start()

func prepare_dash():
	ColoredRectangle.color = Color.ORANGE
	var direction = (character.position - position).normalized()
	# var x = (randf() - 0.5) / 10
	# var y = (randf() - 0.5) / 10
	preparingPosition = direction# + Vector2(x, y)
	mode = Mode.PreparingDash
	modeTimer.wait_time = TIME_TO_PREPARE
	modeTimer.start()

func finish_prepare_dash():
	ColoredRectangle.color = Color.RED
	directionDash = (character.position - position).normalized()
	mode = Mode.Dashing

func finish_dash():
	ColoredRectangle.color = Color.WHITE
	mode = Mode.Standby
	
func finish_standby():
	ColoredRectangle.color = Color.hex(0xba4fc2)
	mode = Mode.Following
	
func receive_damage(direction: Vector2, damage: float):
	super(direction, damage)
	modeTimer.stop()
	finish_dash()

func _on_timer_collision_refresh():
	super()
	finish_standby()
