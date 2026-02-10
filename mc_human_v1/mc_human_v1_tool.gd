@tool
extends BetterMarker3D

const SKIN_TEMPLATE = preload("uid://dtvwc0h2qym6t")

@export var skin_texture: Texture2D:
	set(tex):
		skin_texture = tex
		var mesh_root := get_node("%MeshRoot")
		if mesh_root != null:
			var material: StandardMaterial3D = null
			if skin_texture != null:
				material = SKIN_TEMPLATE.duplicate()
				material.albedo_texture = skin_texture
			for mesh_ins: MeshInstance3D in mesh_root.get_children():
				mesh_ins.set_surface_override_material(0, material)
