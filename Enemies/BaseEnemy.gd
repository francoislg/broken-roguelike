extends CharacterBody2D

class_name BaseEnemy

signal dies

@export_subgroup("Map")
@export_flags("Coins", "Waves", "CaptureTheFlag", "AreaControl") var stage_layer = StageTypes.types.Coins | StageTypes.types.Waves | StageTypes.types.CaptureTheFlag | StageTypes.types.AreaControl

@export_subgroup("Stats")
@export var initialHp: float = 5

@export_subgroup("Respawn")
@export_range(0, 10, 0.1) var timeToRespawnInSec: float = 5
@export var numberOfRespawns: int = -1
@export var respawner: Node2D

@onready var health := $Health
@onready var character: CharacterBody2D = $"/root/Scene/Character"

var remainingRespawns: int = numberOfRespawns
var initialPosition: Vector2
var hp: float
const HIT_KNOCKBACK_FORCE = 800
var collisionTimer = Timer.new()
var respawnTimer = Timer.new()

var isSelected = true

func _ready():
	hp = initialHp
	initialPosition = position
	remainingRespawns = numberOfRespawns
	update_progress_bar()

	add_child(collisionTimer)
	collisionTimer.one_shot = true;
	collisionTimer.wait_time = 1
	collisionTimer.connect("timeout", _on_timer_collision_refresh)
	
	if timeToRespawnInSec > 0:
		respawnTimer.one_shot = true
		respawnTimer.wait_time = timeToRespawnInSec;
		respawnTimer.connect("timeout", respawn)
		add_child(respawnTimer)

func _process(_delta):
	pass

func receive_damage(direction: Vector2, damage: float):
	hp -= damage
	if hp <= 0:
		die()
		emit_signal('dies')
	else:
		velocity = direction * HIT_KNOCKBACK_FORCE
		update_progress_bar()
		# set_collision_mask_value(3, false)
		collisionTimer.start()
		

func update_progress_bar():
	var ratio = hp / initialHp
	health.value = ratio * 100
	var r = lerpf(1, 0, ratio)
	var g = lerpf(0, 1, ratio)
	health.set("modulate", Color(r, g, 0))

var previousProcessMode
func die():
	collisionTimer.stop()
	
	if remainingRespawns == 0:
		queue_free()
	else:
		if remainingRespawns > 0:
			remainingRespawns -= 1
		disable()
		if timeToRespawnInSec > 0:
			respawnTimer.start()
		
func respawn():
	position = respawner.position if respawner != null else initialPosition
	velocity = Vector2.ZERO
	hp = initialHp
	update_progress_bar()
	enable()
	
func disable():
	visible = false
	set_collision_layer_value(3, false)
	set_collision_mask_value(2, false)
	
func enable():
	visible = true
	set_collision_layer_value(3, true)
	set_collision_mask_value(2, true)

func _on_timer_collision_refresh():
	#set_collision_mask_value(3, true)
	pass
