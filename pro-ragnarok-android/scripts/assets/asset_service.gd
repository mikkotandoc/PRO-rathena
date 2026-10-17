extends Node
## Autoload facade for asset providers (sprites + maps). Keeps loading out of gameplay.


var sprite_provider: SpriteAnimationProvider
var map_provider: MapAssetProvider


func _ready() -> void:
	sprite_provider = PlaceholderSpriteProvider.new()
	map_provider = PlaceholderMapProvider.new()


func get_sprite_provider() -> SpriteAnimationProvider:
	return sprite_provider


func get_map_provider() -> MapAssetProvider:
	return map_provider


func set_sprite_provider(provider: SpriteAnimationProvider) -> void:
	sprite_provider = provider


func set_map_provider(provider: MapAssetProvider) -> void:
	map_provider = provider
