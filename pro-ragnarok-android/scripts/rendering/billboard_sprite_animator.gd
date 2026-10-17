class_name BillboardSpriteAnimator
extends Node3D
## Renders an animated 2D character sprite in 3D space, always facing the camera.

signal facing_changed(direction_index: int)
signal animation_changed(mode: String)

@export var character_id: String = "test_adventurer"
@export var pixel_size: float = 0.04

var _sprite: Sprite3D
var _provider: SpriteAnimationProvider
var _walk: Dictionary = {}
var _idle: Dictionary = {}
var _mode: String = "idle"
var _facing: int = 0
var _frame: float = 0.0
var _moving: bool = false


func _ready() -> void:
	_sprite = Sprite3D.new()
	_sprite.name = "Sprite3D"
	_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	_sprite.transparent = true
	_sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	_sprite.pixel_size = pixel_size
	_sprite.centered = true
	_sprite.position = Vector3(0, 1.1, 0)
	_sprite.shaded = false
	_sprite.double_sided = true
	add_child(_sprite)
	var svc := get_node_or_null("/root/AssetService")
	if svc and svc.has_method("get_sprite_provider"):
		_provider = svc.get_sprite_provider()
	else:
		_provider = PlaceholderSpriteProvider.new()
	_load_atlases()
	_apply_region()


func set_moving(moving: bool) -> void:
	if _moving == moving:
		return
	_moving = moving
	var new_mode := "walk" if moving else "idle"
	if new_mode != _mode:
		_mode = new_mode
		_frame = 0.0
		animation_changed.emit(_mode)
	_apply_region()


func set_move_vector(world_velocity: Vector3) -> void:
	var moving := world_velocity.length_squared() > 0.01
	set_moving(moving)
	if moving:
		var idx := SpriteAnimationProvider.direction_index_from_vector(world_velocity)
		if idx != _facing:
			_facing = idx
			facing_changed.emit(_facing)
			_apply_region()


func get_facing() -> int:
	return _facing


func get_mode() -> String:
	return _mode


func _process(delta: float) -> void:
	var atlas := _walk if _mode == "walk" else _idle
	if atlas.is_empty():
		return
	var fps: float = float(atlas.get("fps", 8.0))
	var frames: int = int(atlas.get("frames_per_direction", 1))
	if frames <= 1:
		return
	_frame = fmod(_frame + delta * fps, float(frames))
	_apply_region()


func _load_atlases() -> void:
	_walk = _provider.get_walk_atlas(character_id)
	_idle = _provider.get_idle_atlas(character_id)


func _apply_region() -> void:
	var atlas := _walk if _mode == "walk" else _idle
	if atlas.is_empty() or _sprite == null:
		return
	var tex: Texture2D = atlas.get("texture")
	if tex == null:
		return
	_sprite.texture = tex
	var fw: int = int(atlas.get("frame_width", 48))
	var fh: int = int(atlas.get("frame_height", 64))
	var frames: int = int(atlas.get("frames_per_direction", 1))
	var layout: String = str(atlas.get("layout", "rows_by_direction"))
	var frame_i := int(_frame) % maxi(frames, 1)
	var x := 0
	var y := 0
	if layout == "columns_by_direction":
		x = _facing * fw
		y = 0
	else:
		x = frame_i * fw
		y = _facing * fh
	_sprite.region_enabled = true
	_sprite.region_rect = Rect2(x, y, fw, fh)
