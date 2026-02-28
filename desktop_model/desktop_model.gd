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
			# 鼠标按下，开始拖拽并记录偏移量
			_is_dragging = true
			_drag_offset = DisplayServer.mouse_get_position() - get_window().position
		else:
			# 鼠标抬起，停止拖拽
			_is_dragging = false
			
	elif event is InputEventMouseMotion and _is_dragging:
		# 鼠标移动且处于拖拽状态时，更新窗口位置
		get_window().position = DisplayServer.mouse_get_position() - _drag_offset

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
