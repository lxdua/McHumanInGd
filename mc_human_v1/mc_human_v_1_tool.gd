@tool
extends Node

const SKIN_MATERIAL_TEMPLATE = preload("uid://dtvwc0h2qym6t")

@onready var mesh_root: Node3D = $"../Skeleton/MeshRoot"

@export var skin_texture: Texture2D:
	set(tex):
		skin_texture = tex
		if mesh_root != null:
			var material: StandardMaterial3D = null
			if skin_texture != null:
				material = SKIN_MATERIAL_TEMPLATE.duplicate()
				material.albedo_texture = skin_texture
			for mesh_ins: MeshInstance3D in mesh_root.get_children():
				mesh_ins.set_surface_override_material(0, material)
