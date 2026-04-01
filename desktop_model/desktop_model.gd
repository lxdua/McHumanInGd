extends Node3D

@export var model: Node3D
@export var eyes: Node3D
@export var animation_player: AnimationPlayer
@export var global_mouse_hook: Node 

@export_group("Eye Tracking Settings")
@export var sensitivity: float = 0.002
@export var max_eye_offset: float = 0.6
@export var tracking_speed: float = 12.0
@export var screen_eye_offset: Vector2i = Vector2i(0, 0)

@export_group("Body Tracking Settings")
@export var body_sensitivity: float = 0.0005
@export var max_body_yaw: float = 0.5
@export var body_tracking_speed: float = 5.0

var _initial_eye_position: Vector3
var _initial_body_rotation_y: float
var _is_clicking: bool = false

# 拖拽状态变量
var _is_dragging: bool = false
var _drag_offset: Vector2i = Vector2i()
var _drag_target_pos: Vector2 = Vector2()

@export_group("Drag Settings")
@export var drag_smoothing: float = 20.0

# 用于读取像素的 viewport 图像（每帧更新）
var _viewport_image: Image

func _ready() -> void:
	if eyes:
		_initial_eye_position = eyes.position
	if model:
		_initial_body_rotation_y = model.rotation.y
		
	# 连接全局鼠标钩子信号
	if global_mouse_hook:
		global_mouse_hook.connect("GlobalMouseClick", Callable(self, "_on_global_mouse_click"))

# 处理窗口内的输入事件（用于拖拽）
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 鼠标按下，开始拖拽并记录偏移量，同时初始化目标位置避免首帧跳跃
			_is_dragging = true
			_drag_offset = DisplayServer.mouse_get_position() - get_window().position
			_drag_target_pos = Vector2(get_window().position)
		else:
			# 鼠标抬起，停止拖拽
			_is_dragging = false
			
	elif event is InputEventMouseMotion and _is_dragging:
		# 鼠标移动且处于拖拽状态时，更新目标位置
		_drag_target_pos = Vector2(DisplayServer.mouse_get_position() - _drag_offset)

# 响应全局鼠标点击（用于播放动画）
func _on_global_mouse_click(button_index: int) -> void:
	if not animation_player:
		return
		
	if _is_clicking:
		return
		
	# 1 代表左键，2 代表右键
	if button_index == 1:
		_play_click_animation("left click")
	elif button_index == 2:
		_play_click_animation("right click")

func _play_click_animation(anim_name: String) -> void:
	if animation_player.has_animation(anim_name):
		_is_clicking = true
		animation_player.play(anim_name)
		await animation_player.animation_finished
		_is_clicking = false

func _process(delta: float) -> void:
	var mouse_pos := DisplayServer.mouse_get_position()
	var window_pos := DisplayServer.window_get_position()
	var window_size := DisplayServer.window_get_size()
	
	# --- 透明穿透检测 ---
	if global_mouse_hook:
		var alpha := _get_mouse_pixel_alpha(mouse_pos, window_pos, window_size)
		global_mouse_hook.call("UpdateClickThrough", alpha)
	
	# --- 拖拽平滑插值 ---
	if _is_dragging:
		var current_pos := Vector2(get_window().position)
		var new_pos := current_pos.lerp(_drag_target_pos, drag_smoothing * delta)
		get_window().position = Vector2i(new_pos)

	@warning_ignore("integer_division")
	var screen_center_pos := window_pos + (window_size / 2) + screen_eye_offset
	var screen_diff := mouse_pos - screen_center_pos
	
	if eyes:
		var target_eye_offset := Vector3(
			screen_diff.x * sensitivity,
			-screen_diff.y * sensitivity,
			0.0
		)
		target_eye_offset = target_eye_offset.limit_length(max_eye_offset)
		var target_eye_position := _initial_eye_position + target_eye_offset
		eyes.position = eyes.position.lerp(target_eye_position, tracking_speed * delta)
		
	if model:
		var target_yaw_offset := screen_diff.x * body_sensitivity
		target_yaw_offset = clamp(target_yaw_offset, -max_body_yaw, max_body_yaw)
		var target_rotation_y := _initial_body_rotation_y + target_yaw_offset
		model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, body_tracking_speed * delta)

# 获取鼠标当前位置对应的 Viewport 像素 alpha 值
# 若鼠标在窗口外则返回 0.0（穿透），在窗口内则读取实际像素 alpha
func _get_mouse_pixel_alpha(mouse_pos: Vector2i, window_pos: Vector2i, window_size: Vector2i) -> float:
	# 判断鼠标是否在窗口范围内
	var local_x := mouse_pos.x - window_pos.x
	var local_y := mouse_pos.y - window_pos.y
	if local_x < 0 or local_y < 0 or local_x >= window_size.x or local_y >= window_size.y:
		return 0.0
	
	# 每帧截取一次 Viewport 图像
	var viewport := get_viewport()
	_viewport_image = viewport.get_texture().get_image()
	
	if _viewport_image == null:
		return 1.0
	
	# Viewport 图像坐标与窗口像素坐标一致（DPI缩放时注意scale）
	var sca := get_window().content_scale_factor
	var px := int(local_x * sca)
	var py := int(local_y * sca)
	px = clamp(px, 0, _viewport_image.get_width() - 1)
	py = clamp(py, 0, _viewport_image.get_height() - 1)
	
	return _viewport_image.get_pixel(px, py).a
