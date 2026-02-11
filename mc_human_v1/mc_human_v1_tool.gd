@tool
extends BetterMarker3D

const SKIN_TEMPLATE = preload("uid://dtvwc0h2qym6t")

@export_subgroup("Skin")
@export var skin_texture: Texture2D:
	set(tex):
		skin_texture = tex
		skin_material = SKIN_TEMPLATE.duplicate()
		if skin_texture != null:
			skin_material.albedo_texture = skin_texture
		for mesh_ins: MeshInstance3D in skin_mesh_list:
			mesh_ins.set_surface_override_material(0, skin_material)

@export var skin_material: StandardMaterial3D

@export_subgroup("Mesh")
@export var skin_mesh_list: Array[MeshInstance3D]
