class_name ItemAnimatedMesh
extends MeshInstance3D

enum ProcessCallback { IDLE, PHYSICS }

@export var animation_resource: ItemFrameAnimation:
	set(value):
		animation_resource = value
		current_frame_index = 0
		_time_accumulator = 0.0
		_update_visual()
		_update_process_mode()

@export var process_callback: ProcessCallback = ProcessCallback.IDLE:
	set(value):
		process_callback = value
		_update_process_mode()

@export var playing: bool = false:
	set(value):
		playing = value
		_update_process_mode()

@export var current_frame_index: int = 0:
	set(value):
		if animation_resource and animation_resource.get_frame_count() > 0:
			if animation_resource.loop:
				current_frame_index = value % animation_resource.get_frame_count()
			else:
				current_frame_index = clampi(value, 0, animation_resource.get_frame_count() - 1)
				if value >= animation_resource.get_frame_count():
					playing = false
					emit_signal("animation_finished")
			_update_visual()

signal animation_finished

var _time_accumulator: float = 0.0

func _ready():
	_update_visual()
	_update_process_mode()

func _update_process_mode():
	var should_process := playing and (animation_resource != null)
	set_process(should_process and process_callback == ProcessCallback.IDLE)
	set_physics_process(should_process and process_callback == ProcessCallback.PHYSICS)

func _process(delta: float):
	_advance_animation(delta)

func _physics_process(delta: float):
	_advance_animation(delta)

func _advance_animation(delta: float):
	if animation_resource.get_frame_count() == 0:
		return
	_time_accumulator += delta
	var frame_duration = 1.0 / animation_resource.fps
	if _time_accumulator >= frame_duration:
		var frames_to_advance = int(_time_accumulator / frame_duration)
		_time_accumulator -= frames_to_advance * frame_duration
		current_frame_index += frames_to_advance

func _update_visual():
	if not animation_resource:
		return
	var frame = animation_resource.get_frame(current_frame_index)
	if frame:
		frame.apply_to(self)

func play():
	playing = true

func stop():
	playing = false

func restart():
	current_frame_index = 0
	_time_accumulator = 0.0
	play()
