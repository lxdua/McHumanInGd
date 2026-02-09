extends EditorNode3DGizmoPlugin

func _get_gizmo_name():
	return "BetterMarker3D"

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is BetterMarker3D

func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	var better_marker_3d: BetterMarker3D = gizmo.get_node_3d() as BetterMarker3D
	better_marker_3d.check_para()
	gizmo.add_mesh(better_marker_3d.gizmo_mesh, better_marker_3d.gizmo_material)
	gizmo.add_collision_triangles(better_marker_3d.gizmo_triangle_mesh)
