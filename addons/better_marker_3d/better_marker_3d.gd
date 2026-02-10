@tool
@icon("res://addons/better_marker_3d/Marker3D.svg")
class_name BetterMarker3D extends Node3D

const DITHER_DISSOLVE = preload("uid://bjxu52j7wjk18")

@export_group("Gizmo Properties")

@export var gizmo_color: Color = Color.DARK_GRAY:
	set(value):
		gizmo_color = value
		update_material()
		update_gizmos()

@export_range(0, 1) var gizmo_opacity: float = 0.8:
	set(value):
		gizmo_opacity = value
		update_material()
		update_gizmos()

@export var gizmo_scale: float = 1.0:
	set(value):
		gizmo_scale = max(value, 0.0)
		update_mesh()
		update_gizmos()

@export var gizmo_size: Vector3 = Vector3(0.5, 0.5, 0.5):
	set(value):
		gizmo_size =  value.clamp(Vector3.ZERO, Vector3.ONE)
		update_mesh()
		update_gizmos()

@export_group("Quick Size Presets")
@export_tool_button("Tiny Cube", "CollisionShape3D") var quick_func_0 := func():
	_quick_set_gizmo_size(Vector3(0.1, 0.1, 0.1), "Tiny Cube")
@export_tool_button("Y Panel", "CollisionShape3D") var quick_func_1 := func():
	_quick_set_gizmo_size(Vector3(0.5, 0.1, 0.5), "Y Panel")
@export_tool_button("X Panel", "CollisionShape3D") var quick_func_2 := func():
	_quick_set_gizmo_size(Vector3(0.1, 0.5, 0.5), "X Panel")
@export_tool_button("Z Panel", "CollisionShape3D") var quick_func_3 := func():
	_quick_set_gizmo_size(Vector3(0.5, 0.5, 0.1), "Z Panel")

func _quick_set_gizmo_size(value: Vector3, action_name: String):
	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Quick Size Presets: %s" % action_name)
	undo_redo.add_do_property(self, "gizmo_size", value)
	undo_redo.add_undo_property(self, "gizmo_size", gizmo_size)
	undo_redo.commit_action()

var gizmo_material: ShaderMaterial

var gizmo_mesh: Mesh
var gizmo_triangle_mesh: TriangleMesh

func update_material():
	if not gizmo_material:
		gizmo_material = ShaderMaterial.new()
		gizmo_material.shader = DITHER_DISSOLVE.duplicate()
	gizmo_material.set_shader_parameter("color", gizmo_color)
	gizmo_material.set_shader_parameter("opacity", gizmo_opacity)

func update_mesh():
	if not gizmo_mesh:
		gizmo_mesh = BoxMesh.new()
	gizmo_mesh.size = gizmo_size * gizmo_scale
	gizmo_triangle_mesh = gizmo_mesh.generate_triangle_mesh()

func check_para():
	if not gizmo_material:
		update_material()
	if not gizmo_mesh:
		update_mesh()
