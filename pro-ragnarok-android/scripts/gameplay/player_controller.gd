class_name PlayerController
extends CharacterBody3D
## Gameplay movement: joystick steering + NavigationAgent3D pathfollowing.

signal arrived_at_destination
signal velocity_updated(world_velocity: Vector3)

@export var move_speed: float = 5.5
@export var rotation_snap: bool = false

var _agent: NavigationAgent3D
var _animator: BillboardSpriteAnimator
var _steer: Vector2 = Vector2.ZERO
var _use_path: bool = false


func _ready() -> void:
	_agent = NavigationAgent3D.new()
	_agent.name = "NavigationAgent3D"
	_agent.path_desired_distance = 0.35
	_agent.target_desired_distance = 0.4
	_agent.avoidance_enabled = false
	_agent.radius = 0.35
	_agent.height = 1.6
	add_child(_agent)
	floor_snap_length = 0.3
	up_direction = Vector3.UP


func set_animator(animator: BillboardSpriteAnimator) -> void:
	_animator = animator


func set_steer_input(vector: Vector2) -> void:
	_steer = vector
	if vector.length_squared() > 0.01:
		_use_path = false
		_agent.target_position = global_position


func move_to_world_position(world_pos: Vector3) -> void:
	_steer = Vector2.ZERO
	_use_path = true
	var target := Vector3(world_pos.x, global_position.y, world_pos.z)
	_agent.target_position = target


func get_navigation_agent() -> NavigationAgent3D:
	return _agent


func _physics_process(delta: float) -> void:
	var desired := Vector3.ZERO
	if _steer.length_squared() > 0.01:
		# Camera-relative-ish: map screen joystick X→world X, Y→world -Z (into screen).
		desired = Vector3(_steer.x, 0.0, -_steer.y).normalized() * move_speed
		_use_path = false
	elif _use_path:
		if _agent.is_navigation_finished():
			_use_path = false
			velocity = Vector3.ZERO
			velocity_updated.emit(velocity)
			if _animator:
				_animator.set_move_vector(velocity)
			arrived_at_destination.emit()
			return
		var next := _agent.get_next_path_position()
		var to_next := next - global_position
		to_next.y = 0.0
		if to_next.length_squared() > 0.0001:
			desired = to_next.normalized() * move_speed

	velocity.x = desired.x
	velocity.z = desired.z
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	velocity_updated.emit(Vector3(velocity.x, 0.0, velocity.z))
	if _animator:
		_animator.set_move_vector(Vector3(velocity.x, 0.0, velocity.z))
