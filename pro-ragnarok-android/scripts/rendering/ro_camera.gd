class_name ROCamera
extends Node3D
## Perspective camera resembling classic Ragnarok Online:
## elevated, looking down toward the character, follow-smoothed, pinch-zoomable.

@export var follow_target: Node3D
@export var follow_smoothing: float = 8.0
@export var min_distance: float = 8.0
@export var max_distance: float = 28.0
@export var default_distance: float = 16.0
@export var pitch_degrees: float = 55.0
@export var yaw_degrees: float = 45.0

var _distance: float = 16.0
var _camera: Camera3D


func _ready() -> void:
	_distance = default_distance
	_camera = Camera3D.new()
	_camera.name = "Camera3D"
	_camera.current = true
	_camera.fov = 40.0
	_camera.near = 0.1
	_camera.far = 200.0
	add_child(_camera)
	_apply_rig()


func _process(delta: float) -> void:
	if follow_target == null:
		return
	var target_pos := follow_target.global_position
	global_position = global_position.lerp(target_pos, clampf(follow_smoothing * delta, 0.0, 1.0))
	_apply_rig()


func set_follow_target(target: Node3D) -> void:
	follow_target = target
	if target:
		global_position = target.global_position


func adjust_zoom(factor: float) -> void:
	# factor > 1 zooms out; < 1 zooms in
	_distance = clampf(_distance * factor, min_distance, max_distance)
	_apply_rig()


func set_distance(value: float) -> void:
	_distance = clampf(value, min_distance, max_distance)
	_apply_rig()


func get_distance() -> float:
	return _distance


func get_camera() -> Camera3D:
	return _camera


func screen_point_to_ground(screen_pos: Vector2, ground_y: float = 0.0) -> Variant:
	if _camera == null:
		return null
	var from := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	if absf(dir.y) < 0.0001:
		return null
	var t := (ground_y - from.y) / dir.y
	if t < 0.0:
		return null
	return from + dir * t


func _apply_rig() -> void:
	if _camera == null:
		return
	var pitch := deg_to_rad(pitch_degrees)
	var yaw := deg_to_rad(yaw_degrees)
	var offset := Vector3(
		_distance * sin(yaw) * cos(pitch),
		_distance * sin(pitch),
		_distance * cos(yaw) * cos(pitch)
	)
	_camera.position = offset
	_camera.look_at(global_position + Vector3(0, 0.9, 0), Vector3.UP)
