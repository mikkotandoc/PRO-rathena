class_name PlaceholderMapProvider
extends MapAssetProvider


func get_provider_id() -> String:
	return "placeholder"


func has_map(map_id: String) -> bool:
	return map_id == "demo_field" or map_id.is_empty()


func get_map_descriptor(_map_id: String) -> Dictionary:
	return {
		"scene_path": "res://scenes/world/demo_map.tscn",
		"display_name": "Demo Field",
		"ground_texture": load("res://assets/placeholders/terrain/grass.png"),
	}
