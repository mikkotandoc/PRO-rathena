class_name SafeAreaUtil
extends RefCounted
## Helpers for 16:9 / 20:9 phone safe-area insets.


static func compute_margins(min_pad: Vector4 = Vector4(16, 12, 16, 16)) -> Vector4:
	var safe: Rect2 = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	var left := maxf(float(safe.position.x), min_pad.x)
	var top := maxf(float(safe.position.y), min_pad.y)
	var right := maxf(float(maxi(win.x - int(safe.position.x + safe.size.x), 0)), min_pad.z)
	var bottom := maxf(float(maxi(win.y - int(safe.position.y + safe.size.y), 0)), min_pad.w)
	return Vector4(left, top, right, bottom)


static func aspect_category(size: Vector2 = Vector2.ZERO) -> String:
	if size == Vector2.ZERO:
		var win := DisplayServer.window_get_size()
		size = Vector2(win)
	if size.y <= 0.0:
		return "unknown"
	var aspect := size.x / size.y
	if aspect >= 2.05:
		return "20:9"
	if aspect >= 1.7:
		return "16:9"
	return "other"
