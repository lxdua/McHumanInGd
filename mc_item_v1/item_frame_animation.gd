class_name ItemFrameAnimation extends Resource


@export var fps: float = 12.0
@export var loop: bool = true
@export var frames: Array[ItemFrame] = []

func set_frames_from_textures(textures: Array[Texture2D], pixel_size: float = 0.0625, thickness: float = 0.0625):
	frames.clear()
	for tex in textures:
		var frame := ItemFrame.create(tex, pixel_size, thickness)
		frames.append(frame)

func get_frame_count() -> int:
	return frames.size()

func get_frame(index: int) -> ItemFrame:
	if index >= 0 and index < frames.size():
		return frames[index]
	return null

static func create(textures: Array[Texture2D], anim_fps: float = 12.0, anim_loop: bool = true, pixel_size: float = 0.0625, thickness: float = 0.0625) -> ItemFrameAnimation:
	var anim := ItemFrameAnimation.new()
	anim.fps = anim_fps
	anim.loop = anim_loop
	anim.set_frames_from_textures(textures, pixel_size, thickness)
	return anim
