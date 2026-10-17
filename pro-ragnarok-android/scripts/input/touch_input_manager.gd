class_name TouchInputManager
extends Node
## Aggregates joystick, touch-to-move, and pinch-to-zoom.
## Gameplay consumes normalized intents — not raw OS events.

signal move_vector_changed(vector: Vector2)
signal ground_move_requested(world_position: Vector3)
signal zoom_factor_requested(factor: float)
signal skill_pressed(slot: int)

@export var camera: ROCamera
@export var gameplay_plane_y: float = 0.0
@export var ui_blockers: Array[Control] = []

var _joystick: ProVirtualJoystick
var _joystick_vector: Vector2 = Vector2.ZERO
var _pinch_active: bool = false
var _pinch_start_distance: float = 0.0
var _active_touches: Dictionary = {} # index -> screen position


func setup(joystick: ProVirtualJoystick, cam: ROCamera) -> void:
	_joystick = joystick
	camera = cam
	if _joystick:
		_joystick.direction_changed.connect(_on_joystick_direction)


func _on_joystick_direction(direction: Vector2) -> void:
	_joystick_vector = direction
	move_vector_changed.emit(_joystick_vector)


func get_move_vector() -> Vector2:
	return _joystick_vector


func notify_skill_pressed(slot: int) -> void:
	skill_pressed.emit(slot)


func _input(event: InputEvent) -> void:
	_track_touches(event)
	_handle_pinch(event)
	_handle_touch_to_move(event)
	_handle_desktop_wheel_zoom(event)


func _handle_desktop_wheel_zoom(event: InputEvent) -> void:
	# Desktop debug convenience (touch uses pinch).
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if not mb.pressed:
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_factor_requested.emit(0.92)
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_factor_requested.emit(1.08)
			get_viewport().set_input_as_handled()


func _track_touches(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_active_touches[st.index] = st.position
		else:
			_active_touches.erase(st.index)
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_active_touches[sd.index] = sd.position


func _handle_pinch(event: InputEvent) -> void:
	if _active_touches.size() >= 2:
		var positions: Array = _active_touches.values()
		var dist: float = positions[0].distance_to(positions[1])
		if not _pinch_active:
			_pinch_active = true
			_pinch_start_distance = maxf(dist, 1.0)
		else:
			var factor := _pinch_start_distance / maxf(dist, 1.0)
			# Convert absolute ratio delta into a small multiplicative zoom step.
			var step := clampf(factor, 0.92, 1.08)
			zoom_factor_requested.emit(step)
			_pinch_start_distance = dist
	else:
		_pinch_active = false


func _handle_touch_to_move(event: InputEvent) -> void:
	if _pinch_active:
		return
	if _joystick and _joystick.is_joystick_active():
		return
	var screen_pos := Vector2.ZERO
	var triggered := false
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			screen_pos = st.position
			triggered = true
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			screen_pos = mb.position
			triggered = true
	if not triggered:
		return
	if _is_blocked_by_ui(screen_pos):
		return
	if camera == null:
		return
	var hit: Variant = camera.screen_point_to_ground(screen_pos, gameplay_plane_y)
	if hit == null:
		return
	ground_move_requested.emit(hit as Vector3)


func _is_blocked_by_ui(screen_pos: Vector2) -> bool:
	for ctrl in ui_blockers:
		if ctrl and ctrl.visible and ctrl.get_global_rect().has_point(screen_pos):
			return true
	return false
