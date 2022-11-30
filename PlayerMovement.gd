extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

const WALK_FORCE = 1200
const WALK_MAX_SPEED = 600
const STOP_FORCE = 1300
const JUMP_SPEED = 700
const WALL_GRAVITY_MODIFIER = 0.2

var gravity = 2000 #ProjectSettings.get_setting("physics/2d/default_gravity")

var recently_wall_jumped = false
var buffered_frames_jump = 0
var jump_touched_a_wall = false
var resetWallTimer := Timer.new()

func _ready():
	add_child(resetWallTimer)
	resetWallTimer.wait_time = 0.2
	resetWallTimer.one_shot = true
	resetWallTimer.connect("timeout", _on_timer_reset_wall_jump)

func _physics_process(delta):
	if (Input.is_action_just_pressed("LEFT") || Input.is_action_just_pressed("RIGHT")) and is_on_floor():
		velocity.x = velocity.x / 2

	var walk = WALK_FORCE * (Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"))
	
	if abs(walk) < WALK_FORCE * 0.2:
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta
	
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	
	var touchesRight = test_move(self.transform, Vector2(1, 0))
	var touchesLeft = test_move(self.transform, Vector2(-1, 0))
	var touchesAWall = touchesLeft || touchesRight
	
	if touchesAWall and !is_on_floor():
		jump_touched_a_wall = true
	else:
		jump_touched_a_wall = false
	
	if (touchesLeft):
		velocity.x = clamp(velocity.x, 0, WALK_MAX_SPEED)
	if (touchesRight):
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, 0)
	
	var baseGravity = gravity * delta
	if (touchesAWall and not recently_wall_jumped):
		velocity.y = clamp(velocity.y + baseGravity * WALL_GRAVITY_MODIFIER, 0, 10000)
	else:
		velocity.y += baseGravity
		
	if (Input.is_action_just_pressed("JUMP")):
		buffered_frames_jump = 0.1

	if (buffered_frames_jump > 0):
		if (is_on_floor() or touchesAWall):
			buffered_frames_jump = 0
			velocity.y = -JUMP_SPEED
			if (touchesAWall):
				resetWallTimer.start()
				recently_wall_jumped = true
				if (touchesLeft):
					velocity.x = JUMP_SPEED
				elif (touchesRight):
					velocity.x = -JUMP_SPEED
		else:
			buffered_frames_jump -= delta;

	move_and_slide()
	
	if velocity.x != 0:
		sprite.set_flip_h(velocity.x < 0)
		

func _on_timer_reset_wall_jump():
	recently_wall_jumped = false
