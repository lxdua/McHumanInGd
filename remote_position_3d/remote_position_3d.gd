@tool
class_name RemotePosition3D
extends Node3D

@export var target_node: Node3D:
	set(value):
		target_node = value
		_reset_state()

@export var reference_node: Node3D:
	set(value):
		reference_node = value
		_reset_state()

enum UpdateMode {
	UPDATE_PROCESS,
	UPDATE_PHYSICS_PROCESS,
	UPDATE_NONE
}

@export var update_mode: UpdateMode = UpdateMode.UPDATE_PROCESS:
	set(value):
		update_mode = value
		_update_processing()

@export_group("Settings")

@export var invert_movement: bool = false:
	set(value):
		invert_movement = value
		if _initialized: _update_position()

@export var max_displacement_length: float = 0.0:
	set(value):
		max_displacement_length = max(0.0, value)
		if _initialized: _update_position()

var _initial_target_global_pos: Vector3
var _initial_relative_vector: Vector3
var _initialized: bool = false

func _ready() -> void:
	_update_processing()
	await get_tree().process_frame
	_reset_state()

func _update_processing() -> void:
	set_process(update_mode == UpdateMode.UPDATE_PROCESS)
	set_physics_process(update_mode == UpdateMode.UPDATE_PHYSICS_PROCESS)

func _reset_state() -> void:
	if not target_node or not reference_node:
		_initialized = false
		return
	
	_initial_target_global_pos = target_node.global_position
	_initial_relative_vector = global_position - reference_node.global_position
	_initialized = true

func _process(_delta: float) -> void:
	if _initialized:
		_update_position()

func _physics_process(_delta: float) -> void:
	if _initialized:
		_update_position()

func _update_position() -> void:
	if not target_node or not reference_node:
		return
	var current_relative_vector := global_position - reference_node.global_position
	var offset := _initial_relative_vector - current_relative_vector
	if invert_movement:
		offset = -offset
	if max_displacement_length > 0.0:
		if offset.length() > max_displacement_length:
			offset = offset.limit_length(max_displacement_length)
	target_node.global_position = _initial_target_global_pos + offset
