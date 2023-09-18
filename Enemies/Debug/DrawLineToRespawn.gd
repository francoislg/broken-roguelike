@tool
extends Node2D

var parent: Node2D
var respawner: Node2D

var isParentSelected: bool = false

func _ready():
	if Engine.is_editor_hint():
		var selection: EditorSelection = EditorPlugin.new().get_editor_interface().get_selection()
		selection.connect("selection_changed", on_selection_changed)

func on_selection_changed():
	parent = get_owner()
	if parent:
		var id = parent.get_instance_id();
		var selection: EditorSelection = EditorPlugin.new().get_editor_interface().get_selection()
		var nodes = selection.get_transformable_selected_nodes()
		isParentSelected = id in nodes.map(func(node): return node.get_instance_id())
		if isParentSelected:
			respawner = parent.get("respawner")

		queue_redraw()

func _process(_delta):
	if Engine.is_editor_hint() and respawner != null and isParentSelected:
		queue_redraw()

func _draw():
	if Engine.is_editor_hint() and respawner != null and isParentSelected:
		draw_line(Vector2.ZERO, respawner.global_position - parent.global_position, Color.DARK_GREEN)
