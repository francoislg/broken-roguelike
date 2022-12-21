@tool
extends CharacterBody2D

class_name BaseEnemy

signal dies

@export_flags("Coins", "Waves", "CaptureTheFlag", "AreaControl") var stage_layer = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag | StageTypes.types.AreaControl

@onready var health := $Health
@onready var character: CharacterBody2D = $"/root/Scene/Character"

@export var initialHp: float = 5
var initialPosition: Vector2
var hp: float
const HIT_KNOCKBACK_FORCE = 500
var collisionTimer = Timer.new()
var freeOnDeath = true

func _ready():
	hp = initialHp
	initialPosition = position
	update_progress_bar(1)

	add_child(collisionTimer)
	collisionTimer.one_shot = true;
	collisionTimer.wait_time = 1
	collisionTimer.connect("timeout", _on_timer_collision_refresh)

func receive_damage(direction: Vector2, damage: float):
	hp -= damage
	if hp <= 0:
		die()
		emit_signal('dies')
	else:
		velocity = direction * HIT_KNOCKBACK_FORCE
		update_progress_bar(hp / initialHp)
		# set_collision_mask_value(3, false)
		collisionTimer.start()
		

func update_progress_bar(ratio: float):
	health.value = ratio * 100
	var r = lerpf(1, 0, ratio)
	var g = lerpf(0, 1, ratio)
	health.set("modulate", Color(r, g, 0))

func die():
	if freeOnDeath:
		queue_free()
	else:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		
func respawn():
	position = initialPosition
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func disable_free_on_death():
	freeOnDeath = false

func _on_timer_collision_refresh():
	#set_collision_mask_value(3, true)
	pass
