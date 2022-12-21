extends BaseEnemy

@onready var ColoredRectangle := $ColoredRectangle

const BASE_SPEED = 400
const DASH_SPEED = 2000
const PREPARING_SPEED = 200
# The higher this is, the faster the enemy will get to speed
const TIME_TO_GET_TO_SPEED = 1400
const DISTANCE_FOR_DASH = 120

const TIME_TO_PREPARE = 1
const TIME_TO_DASH = 0.25
const TIME_TO_COOLDOWN = 1

enum Mode { Following, PreparingDash, Dashing, PostDashing, Damaged }

var mode := Mode.Following
var modeTimer = Timer.new()
var directionDash := Vector2.ZERO
var flippedPreparation := false
var preparationVariation: float

func _ready():
	super()
	modeTimer.one_shot = true
	modeTimer.wait_time = 1
	modeTimer.connect("timeout", nextMode)
	add_child(modeTimer)

func _process(delta):
	super(delta)
	var diff = character.position - position
	
	if mode == Mode.Following and diff.length() <= DISTANCE_FOR_DASH:
		prepare_dash()

func _physics_process(delta):
	var normalizedDiff = (character.position - position).normalized()
	
	match (mode):
		Mode.Following:
			velocity = velocity.move_toward(normalizedDiff * BASE_SPEED, delta * TIME_TO_GET_TO_SPEED)
		Mode.PreparingDash:
			velocity = velocity.move_toward((1 if flippedPreparation else -1) * normalizedDiff.orthogonal().rotated(preparationVariation) * BASE_SPEED / 4, delta * TIME_TO_GET_TO_SPEED)
		Mode.Dashing:
			velocity = velocity.move_toward(directionDash * DASH_SPEED, delta * TIME_TO_GET_TO_SPEED * 4)
		Mode.PostDashing:
			velocity = velocity.move_toward(normalizedDiff * BASE_SPEED / 2, delta * TIME_TO_GET_TO_SPEED * 2)
		_:
			velocity = velocity.move_toward(Vector2.ZERO, delta * TIME_TO_GET_TO_SPEED * 4)
	
	move_and_collide(velocity * delta)

func nextMode():
	match(mode):
		Mode.PreparingDash:
			finish_prepare_dash()
			modeTimer.wait_time = TIME_TO_DASH
			modeTimer.start()
		Mode.Dashing:
			finish_dash()
			modeTimer.wait_time = TIME_TO_COOLDOWN
			modeTimer.start()
		Mode.PostDashing:
			finish_post_dash()

func prepare_dash():
	ColoredRectangle.color = Color.ORANGE
	mode = Mode.PreparingDash
	flippedPreparation = randi_range(0, 1) == 0
	preparationVariation = randf_range(0, 0.0833333)
	modeTimer.wait_time = TIME_TO_PREPARE
	modeTimer.start()

func finish_prepare_dash():
	ColoredRectangle.color = Color.RED
	directionDash = (character.position - position).normalized()
	mode = Mode.Dashing

func finish_dash():
	ColoredRectangle.color = Color.WHITE
	mode = Mode.PostDashing
	
func finish_post_dash():
	ColoredRectangle.color = Color.hex(0xba4fc2)
	mode = Mode.Following
	
func receive_damage(direction: Vector2, damage: float):
	super(direction, damage)
	modeTimer.stop()
	ColoredRectangle.color = Color.WHITE
	mode = Mode.Damaged

func _on_timer_collision_refresh():
	super()
	finish_post_dash()
