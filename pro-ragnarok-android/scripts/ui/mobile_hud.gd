class_name MobileHud
extends CanvasLayer
## Mobile HUD: joystick (LL), skill buttons (LR), FPS, graphics quality, safe-area insets.

signal skill_pressed(slot: int)

@onready var _root: Control = $SafeArea
@onready var _joystick: ProVirtualJoystick = $SafeArea/Joystick
@onready var _skills: Control = $SafeArea/Skills
@onready var _fps_label: Label = $SafeArea/TopBar/FpsLabel
@onready var _quality_btn: Button = $SafeArea/TopBar/QualityButton
@onready var _status_label: Label = $SafeArea/TopBar/StatusLabel

var _session: DemoSession


func _ready() -> void:
	layer = 10
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	if _quality_btn:
		_quality_btn.pressed.connect(_on_quality_pressed)
		_refresh_quality_label()
	for i in range(4):
		var btn := _skills.get_node_or_null("Skill%d" % i) as BaseButton
		if btn:
			btn.pressed.connect(_on_skill.bind(i))
	if _status_label:
		_status_label.text = "OFFLINE DEMO"


func bind_session(session: DemoSession) -> void:
	_session = session


func get_joystick() -> ProVirtualJoystick:
	return _joystick


func get_input_blockers() -> Array[Control]:
	var arr: Array[Control] = []
	if _joystick:
		arr.append(_joystick)
	if _skills:
		arr.append(_skills)
	if _quality_btn:
		arr.append(_quality_btn)
	return arr


func _process(_delta: float) -> void:
	if GraphicsSettings and GraphicsSettings.show_fps and _fps_label:
		_fps_label.text = "FPS: %d" % int(Engine.get_frames_per_second())


func _on_quality_pressed() -> void:
	if GraphicsSettings:
		GraphicsSettings.cycle_quality()
		_refresh_quality_label()


func _refresh_quality_label() -> void:
	if _quality_btn and GraphicsSettings:
		_quality_btn.text = "GFX: %s" % GraphicsSettings.quality_name()


func _on_skill(slot: int) -> void:
	skill_pressed.emit(slot)


func _apply_safe_area() -> void:
	if _root == null:
		return
	var safe: Rect2 = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	# Convert absolute safe rect into margins relative to the window.
	var left := float(safe.position.x)
	var top := float(safe.position.y)
	var right := float(maxi(win.x - int(safe.position.x + safe.size.x), 0))
	var bottom := float(maxi(win.y - int(safe.position.y + safe.size.y), 0))
	# Always keep a small pad for bezels / 20:9 punch-holes.
	left = maxf(left, 16.0)
	right = maxf(right, 16.0)
	top = maxf(top, 12.0)
	bottom = maxf(bottom, 16.0)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.offset_left = left
	_root.offset_top = top
	_root.offset_right = -right
	_root.offset_bottom = -bottom
