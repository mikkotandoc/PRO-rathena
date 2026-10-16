class_name ProVirtualJoystick
extends Control
## Lower-left virtual joystick for touch movement.

signal direction_changed(direction: Vector2)
signal pressed_changed(is_pressed: bool)

@export var radius: float = 72.0
@export var deadzone: float = 0.18

var _touch_index: int = -1
var _knob_center: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _base: Control
var _knob: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(radius * 2.4, radius * 2.4)
	_build_visuals()
	_knob_center = size * 0.5
	_knob_pos = _knob_center
	resized.connect(_on_resized)


func get_direction() -> Vector2:
	return _direction


func is_joystick_active() -> bool:
	return _touch_index != -1


func _on_resized() -> void:
	_knob_center = size * 0.5
	if _touch_index == -1:
		_knob_pos = _knob_center
	_update_visuals()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed and _touch_index == -1:
			_touch_index = st.index
			_update_from_local(st.position)
			pressed_changed.emit(true)
			accept_event()
		elif not st.pressed and st.index == _touch_index:
			_reset()
			accept_event()
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if sd.index == _touch_index:
			_update_from_local(sd.position)
			accept_event()
	elif event is InputEventMouseButton and not DisplayServer.is_touchscreen_available():
		# Desktop debug: mouse acts as touch via project setting, but keep fallback.
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_touch_index = 0
				_update_from_local(mb.position)
				pressed_changed.emit(true)
			else:
				_reset()
			accept_event()
	elif event is InputEventMouseMotion and _touch_index != -1:
		var mm := event as InputEventMouseMotion
		if mm.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_update_from_local(mm.position)
			accept_event()


func _update_from_local(local_pos: Vector2) -> void:
	var offset := local_pos - _knob_center
	if offset.length() > radius:
		offset = offset.normalized() * radius
	_knob_pos = _knob_center + offset
	var dir := offset / radius
	if dir.length() < deadzone:
		dir = Vector2.ZERO
	else:
		dir = dir.normalized() * inverse_lerp(deadzone, 1.0, dir.length())
	if not dir.is_equal_approx(_direction):
		_direction = dir
		direction_changed.emit(_direction)
	_update_visuals()


func _reset() -> void:
	_touch_index = -1
	_knob_pos = _knob_center
	if _direction != Vector2.ZERO:
		_direction = Vector2.ZERO
		direction_changed.emit(_direction)
	pressed_changed.emit(false)
	_update_visuals()


func _build_visuals() -> void:
	_base = ColorRect.new()
	_base.name = "Base"
	_base.color = Color(0.1, 0.12, 0.16, 0.45)
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_base)
	_knob = ColorRect.new()
	_knob.name = "Knob"
	_knob.color = Color(0.85, 0.9, 1.0, 0.75)
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_knob)
	_update_visuals()


func _update_visuals() -> void:
	if _base == null:
		return
	var base_size := Vector2(radius * 2.0, radius * 2.0)
	_base.size = base_size
	_base.position = _knob_center - base_size * 0.5
	var knob_size := Vector2(radius * 0.9, radius * 0.9)
	_knob.size = knob_size
	_knob.position = _knob_pos - knob_size * 0.5
