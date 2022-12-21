@tool
extends Node2D

var parent: Node2D
var respawner: Node2D

var isParentSelected: bool = false

func _ready():
	if Engine.is_editor_hint():
		parent = get_owner()
		
		var selection = EditorPlugin.new().get_editor_interface().get_selection()
		selection.connect("selection_changed", func():
			isParentSelected = parent.get_instance_id() in selection.get_selected_nodes().map(func(node): return node.get_instance_id())
			
			if isParentSelected:
				check_respawner_prop()
			
			queue_redraw()
		)


func check_respawner_prop():
	if "_editor_prop_ptr_respawner" in parent.get_meta_list():
		var respawnerPath = parent.get_meta("_editor_prop_ptr_respawner")
		if respawnerPath:
			respawner = parent.get_node(respawnerPath)


func _process(_delta):
	if Engine.is_editor_hint() and respawner != null and isParentSelected:
		queue_redraw()

func _draw():
	if Engine.is_editor_hint() and respawner != null and isParentSelected:
		draw_line(Vector2.ZERO, respawner.global_position - parent.global_position, Color.DARK_GREEN)
