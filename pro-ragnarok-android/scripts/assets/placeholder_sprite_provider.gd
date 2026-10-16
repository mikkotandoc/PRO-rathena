class_name PlaceholderSpriteProvider
extends SpriteAnimationProvider
## Original placeholder walk/idle atlases — no commercial RO art.


func get_provider_id() -> String:
	return "placeholder"


func has_character(character_id: String) -> bool:
	return character_id == "test_adventurer" or character_id.is_empty()


func get_walk_atlas(_character_id: String) -> Dictionary:
	var tex := load("res://assets/placeholders/character/placeholder_walk.png") as Texture2D
	return {
		"texture": tex,
		"frame_width": 48,
		"frame_height": 64,
		"frames_per_direction": 4,
		"fps": 8.0,
		"mode": "walk",
		"layout": "rows_by_direction",
	}


func get_idle_atlas(_character_id: String) -> Dictionary:
	var tex := load("res://assets/placeholders/character/placeholder_idle.png") as Texture2D
	return {
		"texture": tex,
		"frame_width": 48,
		"frame_height": 64,
		"frames_per_direction": 1,
		"fps": 1.0,
		"mode": "idle",
		"layout": "columns_by_direction",
	}
