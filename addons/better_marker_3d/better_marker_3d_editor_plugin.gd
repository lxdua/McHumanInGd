@tool
extends EditorPlugin

const BetterMarker3dGizmoPlugin = preload("uid://bhuqsfx1w6115")

var gizmo_plugin = BetterMarker3dGizmoPlugin.new()

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree():
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
