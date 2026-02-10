class_name ItemFrame extends Resource

@export var mesh: ArrayMesh
@export var material: StandardMaterial3D
@export var original_texture: Texture2D

func apply_to(mesh_ins: MeshInstance3D):
	if mesh_ins:
		mesh_ins.mesh = mesh
		mesh_ins.material_override = material

static func create(texture: Texture2D, pixel_size: float = 0.0625, thickness: float = 0.0625) -> ItemFrame:
	if not texture:
		return null
		
	var image := texture.get_image()

	var w := image.get_width()
	var h := image.get_height()
	
	# --- 1. 构建 Mesh ---
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var uv_pixel_w := 1.0 / w
	var uv_pixel_h := 1.0 / h
	var total_world_w := w * pixel_size
	var total_world_h := h * pixel_size
	var offset_x := -total_world_w / 2.0
	var offset_y := total_world_h / 2.0
	
	for x in range(w):
		for y in range(h):
			var color := image.get_pixel(x, y)
			if color.a == 0: continue
			
			# 顶点位置
			var p_left := offset_x + (x * pixel_size)
			var p_right := offset_x + ((x + 1) * pixel_size)
			var p_top := offset_y - (y * pixel_size)
			var p_bottom := offset_y - ((y + 1) * pixel_size)
			var z_front := thickness / 2.0
			var z_back := -thickness / 2.0
			
			# UV
			var uv_l := x * uv_pixel_w
			var uv_r := (x + 1) * uv_pixel_w
			var uv_t := y * uv_pixel_h
			var uv_b := (y + 1) * uv_pixel_h
			
			# 正面
			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(uv_l, uv_b)); st.add_vertex(Vector3(p_left, p_bottom, z_front))
			st.set_uv(Vector2(uv_l, uv_t)); st.add_vertex(Vector3(p_left, p_top, z_front))
			st.set_uv(Vector2(uv_r, uv_t)); st.add_vertex(Vector3(p_right, p_top, z_front))
			st.set_uv(Vector2(uv_r, uv_t)); st.add_vertex(Vector3(p_right, p_top, z_front))
			st.set_uv(Vector2(uv_r, uv_b)); st.add_vertex(Vector3(p_right, p_bottom, z_front))
			st.set_uv(Vector2(uv_l, uv_b)); st.add_vertex(Vector3(p_left, p_bottom, z_front))

			# 背面
			st.set_normal(Vector3(0, 0, -1))
			st.set_uv(Vector2(uv_r, uv_t)); st.add_vertex(Vector3(p_right, p_top, z_back))
			st.set_uv(Vector2(uv_l, uv_t)); st.add_vertex(Vector3(p_left, p_top, z_back))
			st.set_uv(Vector2(uv_l, uv_b)); st.add_vertex(Vector3(p_left, p_bottom, z_back))
			st.set_uv(Vector2(uv_l, uv_b)); st.add_vertex(Vector3(p_left, p_bottom, z_back))
			st.set_uv(Vector2(uv_r, uv_b)); st.add_vertex(Vector3(p_right, p_bottom, z_back))
			st.set_uv(Vector2(uv_r, uv_t)); st.add_vertex(Vector3(p_right, p_top, z_back))

			# 侧面
			var center_uv := Vector2((x + 0.5) * uv_pixel_w, (y + 0.5) * uv_pixel_h)
			if x + 1 >= w or image.get_pixel(x + 1, y).a == 0: 
				_build_quad(st, Vector3(p_right, p_top, z_front), Vector3(p_right, p_top, z_back), Vector3(p_right, p_bottom, z_back), Vector3(p_right, p_bottom, z_front), Vector3(1, 0, 0), center_uv)
			if x - 1 < 0 or image.get_pixel(x - 1, y).a == 0: 
				_build_quad(st, Vector3(p_left, p_top, z_back), Vector3(p_left, p_top, z_front), Vector3(p_left, p_bottom, z_front), Vector3(p_left, p_bottom, z_back), Vector3(-1, 0, 0), center_uv)
			if y - 1 < 0 or image.get_pixel(x, y - 1).a == 0:
				_build_quad(st, Vector3(p_left, p_top, z_back), Vector3(p_right, p_top, z_back), Vector3(p_right, p_top, z_front), Vector3(p_left, p_top, z_front), Vector3(0, 1, 0), center_uv)
			if y + 1 >= h or image.get_pixel(x, y + 1).a == 0:
				_build_quad(st, Vector3(p_left, p_bottom, z_front), Vector3(p_right, p_bottom, z_front), Vector3(p_right, p_bottom, z_back), Vector3(p_left, p_bottom, z_back), Vector3(0, -1, 0), center_uv)

	st.index()
	var generated_mesh = st.commit()
	
	# --- 2. 构建 Material ---
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	mat.cull_mode = BaseMaterial3D.CULL_BACK
	mat.roughness = 1.0
	
	# --- 3. 打包进 Resource ---
	var item_frame := ItemFrame.new()
	item_frame.mesh = generated_mesh
	item_frame.material = mat
	item_frame.original_texture = texture
	
	return item_frame

static func _build_quad(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3, normal: Vector3, uv: Vector2):
	st.set_normal(normal); st.set_uv(uv); st.add_vertex(v1)
	st.add_vertex(v2); st.add_vertex(v3); st.add_vertex(v1)
	st.add_vertex(v3); st.add_vertex(v4)
