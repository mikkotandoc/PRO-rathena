class_name MapAssetProvider
extends RefCounted
## Modular interface for 3D map / terrain assets.
## Future implementations may stream rsw/gnd-derived meshes; Phase 1 is placeholders.


func get_provider_id() -> String:
	return "base"


func has_map(_map_id: String) -> bool:
	return false


## Returns { scene_path: String, display_name: String, ground_texture: Texture2D }
func get_map_descriptor(_map_id: String) -> Dictionary:
	return {}
