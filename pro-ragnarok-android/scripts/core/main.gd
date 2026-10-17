extends Node3D
## Main entry: loads placeholder map + player, starts offline demo session.


func _ready() -> void:
	var asset_svc := get_node_or_null("/root/AssetService")
	var map_provider: MapAssetProvider
	if asset_svc:
		map_provider = asset_svc.get_map_provider()
	else:
		map_provider = PlaceholderMapProvider.new()
	var desc := map_provider.get_map_descriptor("demo_field")
	var map_scene_path: String = str(desc.get("scene_path", "res://scenes/world/demo_map.tscn"))
	var map_packed := load(map_scene_path) as PackedScene
	if map_packed == null:
		push_error("Failed to load demo map: %s" % map_scene_path)
		return
	var map := map_packed.instantiate() as DemoMap
	map.name = "DemoMap"
	$World.add_child(map)

	var player_packed := load("res://scenes/character/player.tscn") as PackedScene
	var player := player_packed.instantiate() as PlayerController
	player.name = "Player"
	player.position = map.get_spawn_position()
	$World.add_child(player)

	var animator := player.get_node("BillboardSpriteAnimator") as BillboardSpriteAnimator
	player.set_animator(animator)

	var camera := ROCamera.new()
	camera.name = "ROCamera"
	$World.add_child(camera)

	var hud_packed := load("res://scenes/ui/mobile_hud.tscn") as PackedScene
	var hud := hud_packed.instantiate() as MobileHud
	hud.name = "MobileHud"
	add_child(hud)

	var session := DemoSession.new()
	session.name = "DemoSession"
	add_child(session)
	session.start(player, camera, hud)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-50, 35, 0)
	sun.light_energy = 1.1
	var gfx := get_node_or_null("/root/GraphicsSettings")
	sun.shadow_enabled = gfx == null or gfx.quality != gfx.Quality.LOW
	$World.add_child(sun)

	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.55, 0.72, 0.92)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.6, 0.7)
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = e
	$World.add_child(env)

	print("[Main] Offline demo map ready — aspect=", SafeAreaUtil.aspect_category())
