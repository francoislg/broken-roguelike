extends Camera2D

@onready var Stage := %Stage

func _ready():
	limit_bottom = Stage.Bounds.Bottom
	limit_right = Stage.Bounds.Right
