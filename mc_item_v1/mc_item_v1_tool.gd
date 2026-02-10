@tool
extends Node

@export var frames: Array[Texture2D]

@export_tool_button("Create anim") var create_anim_func := func():
	for tex in frames:
		if tex.get_image().is_compressed():
			print("有压缩过的纹理，导入失败")
			return
	var item_mesh := get_node("%McItemAnimatedMesh")
	if item_mesh != null:
		item_mesh.animation_resource = ItemFrameAnimation.create(frames)
	print("导入Item动画")
