extends Area2D

class_name Area

signal area_finished

@onready var CollisionShape := $CollisionShape2D

var time_to_complete_in_sec = 5
var is_counting = false
var initialColor: Color

func _ready():
	initialColor = CollisionShape.color

func _process(delta):
	if is_counting:
		time_to_complete_in_sec -= delta
		if time_to_complete_in_sec <= 0:
			emit_signal("area_finished")
			is_counting = false
			CollisionShape.color = Color.GREEN

func start_counting():
	if time_to_complete_in_sec > 0:
		CollisionShape.color = Color.YELLOW_GREEN
		is_counting = true

func stop_counting():
	if time_to_complete_in_sec > 0:
		CollisionShape.color = initialColor
		is_counting = false

func _on_body_entered(body):
	if body is Player:
		start_counting()


func _on_body_exited(body):
	if body is Player:
		stop_counting()
