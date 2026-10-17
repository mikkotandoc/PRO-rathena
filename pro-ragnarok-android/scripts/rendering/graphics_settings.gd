extends Node
## Autoload: configurable graphics quality + FPS overlay state.

signal quality_changed(level: int)

enum Quality {
	LOW,
	MEDIUM,
	HIGH,
}

var quality: int = Quality.MEDIUM
var show_fps: bool = true


func _ready() -> void:
	apply_quality(quality)


func set_quality(level: int) -> void:
	quality = clampi(level, Quality.LOW, Quality.HIGH)
	apply_quality(quality)
	quality_changed.emit(quality)


func cycle_quality() -> int:
	set_quality((quality + 1) % 3)
	return quality


func quality_name() -> String:
	match quality:
		Quality.LOW:
			return "Low"
		Quality.HIGH:
			return "High"
		_:
			return "Medium"


func apply_quality(level: int) -> void:
	var vp := get_viewport()
	if vp == null:
		return
	match level:
		Quality.LOW:
			vp.scaling_3d_scale = 0.65
			vp.msaa_3d = Viewport.MSAA_DISABLED
			ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", 0)
		Quality.HIGH:
			vp.scaling_3d_scale = 1.0
			vp.msaa_3d = Viewport.MSAA_4X
		_:
			vp.scaling_3d_scale = 0.85
			vp.msaa_3d = Viewport.MSAA_2X
