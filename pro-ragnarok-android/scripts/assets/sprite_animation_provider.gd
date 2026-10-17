class_name SpriteAnimationProvider
extends RefCounted
## Modular interface for classic 2D sprite animation atlases.
## Implementations may later load GRAVITY-style packs; Phase 1 uses placeholders only.

const DIR_NAMES: PackedStringArray = [
	"s", "sw", "w", "nw", "n", "ne", "e", "se"
]


func get_provider_id() -> String:
	return "base"


func has_character(_character_id: String) -> bool:
	return false


## Returns a Dictionary:
## { texture: Texture2D, frame_width: int, frame_height: int,
##   frames_per_direction: int, fps: float, mode: String }
func get_walk_atlas(_character_id: String) -> Dictionary:
	return {}


func get_idle_atlas(_character_id: String) -> Dictionary:
	return {}


## Map world movement vector to an 8-way facing index (0=S … 7=SE).
static func direction_index_from_vector(v: Vector3) -> int:
	if v.length_squared() < 0.0001:
		return 0
	var flat := Vector2(v.x, v.z).normalized()
	# aim atan2 so 0 ≈ south (+z), increasing counter-clockwise through SW, W, …
	var angle := atan2(-flat.x, flat.y) # [-PI, PI], 0 = +z (south)
	var sector := int(round(angle / (PI / 4.0)))
	if sector < 0:
		sector += 8
	return clampi(sector, 0, 7)
