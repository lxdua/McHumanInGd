@tool
class_name BetterMarker3D extends Marker3D

const DITHER_DISSOLVE = preload("uid://bjxu52j7wjk18")

@export_group("Gizmo Properties")

@export var gizmo_color: Color = Color.DARK_GRAY:
	set(v):
		gizmo_color = v
		update_material()
		update_gizmos()

@export_range(0, 1) var gizmo_opacity: float = 0.8:
	set(v):
		gizmo_opacity = v
		update_material()
		update_gizmos()

@export var gizmo_scale: float = 1.0:
	set(v):
		gizmo_scale = max(v, 0.0)
		update_mesh()
		update_gizmos()

@export var gizmo_size: Vector3 = Vector3(0.5, 0.5, 0.5):
	set(v):
		gizmo_size =  v.clamp(Vector3.ZERO, Vector3.ONE)
		update_mesh()
		update_gizmos()

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

@export_group("Quick Size Presets")
@export_tool_button("Tiny Cube") var quick_func_0 := func(): gizmo_size = Vector3(0.1, 0.1, 0.1)
@export_tool_button("Y Panel") var quick_func_1 := func(): gizmo_size = Vector3(0.5, 0.1, 0.5)
@export_tool_button("X Panel") var quick_func_2 := func(): gizmo_size = Vector3(0.1, 0.5, 0.5)
@export_tool_button("Z Panel") var quick_func_3 := func(): gizmo_size = Vector3(0.5, 0.5, 0.1)
