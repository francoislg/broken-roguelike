extends CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

@export var color = Color.WHITE

func _draw():
	var ext:Vector2 = shape.extents
	var rect:Rect2 = Rect2(Vector2(-ext.x, -ext.y), ext*2)
	draw_rect(rect, color, true)
