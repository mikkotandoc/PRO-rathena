class_name DemoSession
extends Node
## Offline demo orchestration: wires input → gameplay → rendering without networking.

var player: PlayerController
var camera: ROCamera
var input_manager: TouchInputManager
var hud: MobileHud
var _wired: bool = false


func start(p_player: PlayerController, p_camera: ROCamera, p_hud: MobileHud) -> void:
	player = p_player
	camera = p_camera
	hud = p_hud
	if camera and player:
		camera.set_follow_target(player)
	_setup_input()
	if hud:
		hud.bind_session(self)


func _setup_input() -> void:
	if _wired:
		return
	_wired = true
	input_manager = TouchInputManager.new()
	input_manager.name = "TouchInputManager"
	add_child(input_manager)
	var joystick: ProVirtualJoystick = null
	if hud:
		joystick = hud.get_joystick()
		input_manager.ui_blockers = hud.get_input_blockers()
		hud.skill_pressed.connect(input_manager.notify_skill_pressed)
	input_manager.setup(joystick, camera)
	input_manager.move_vector_changed.connect(_on_move_vector)
	input_manager.ground_move_requested.connect(_on_ground_move)
	input_manager.zoom_factor_requested.connect(_on_zoom)
	input_manager.skill_pressed.connect(_on_skill)


func _on_move_vector(vector: Vector2) -> void:
	if player:
		player.set_steer_input(vector)


func _on_ground_move(world_pos: Vector3) -> void:
	if player:
		player.move_to_world_position(world_pos)


func _on_zoom(factor: float) -> void:
	if camera:
		camera.adjust_zoom(factor)


func _on_skill(slot: int) -> void:
	print("[DemoSession] placeholder skill ", slot, " (offline — no server cast)")
