extends Camera2D

@onready var StagesManager := %StagesManager

func _ready():
	StagesManager.connect("new_stage", func(stage):
		limit_bottom = stage.Bounds.Bottom + 50
		limit_right = stage.Bounds.Right
	)
