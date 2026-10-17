extends SceneTree
## Headless test runner for Phase 1: movement, navigation helpers, scene loading.
## Usage: godot --headless --path . -s res://tests/run_tests.gd

var _passed: int = 0
var _failed: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== PRO-Ragnarok Phase 1 Tests ===")
	_test_direction_indexing()
	_test_safe_area_aspect()
	_test_network_interface_offline()
	_test_asset_providers()
	_test_scene_loading()
	await _test_navigation_and_movement()
	print("=== Results: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _ok(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_passed += 1
		print("PASS: ", name)
	else:
		_failed += 1
		print("FAIL: ", name, (" — " + detail) if detail else "")


func _test_direction_indexing() -> void:
	_ok("south facing", SpriteAnimationProvider.direction_index_from_vector(Vector3(0, 0, 1)) == 0)
	_ok("east facing", SpriteAnimationProvider.direction_index_from_vector(Vector3(1, 0, 0)) == 6)
	_ok("west facing", SpriteAnimationProvider.direction_index_from_vector(Vector3(-1, 0, 0)) == 2)
	_ok("north facing", SpriteAnimationProvider.direction_index_from_vector(Vector3(0, 0, -1)) == 4)
	_ok("idle zero vector defaults south", SpriteAnimationProvider.direction_index_from_vector(Vector3.ZERO) == 0)


func _test_safe_area_aspect() -> void:
	_ok("16:9 category", SafeAreaUtil.aspect_category(Vector2(1920, 1080)) == "16:9")
	_ok("20:9 category", SafeAreaUtil.aspect_category(Vector2(2400, 1080)) == "20:9")
	_ok("other category", SafeAreaUtil.aspect_category(Vector2(1024, 768)) == "other")


func _test_network_interface_offline() -> void:
	var net := OfflineNetworkClient.new()
	_ok("offline not connected", net.is_connected_to_server() == false)
	_ok("offline connect refused", net.connect_to_server("127.0.0.1", 6900) == ERR_UNAVAILABLE)
	_ok("offline send refused", net.send_raw(PackedByteArray([1, 2, 3])) == ERR_UNAVAILABLE)
	_ok("state disconnected", net.get_connection_state() == NetworkClientBase.ConnectionState.DISCONNECTED)
	net.free()


func _test_asset_providers() -> void:
	var sprites := PlaceholderSpriteProvider.new()
	var maps := PlaceholderMapProvider.new()
	_ok("sprite provider id", sprites.get_provider_id() == "placeholder")
	_ok("has test character", sprites.has_character("test_adventurer"))
	var walk := sprites.get_walk_atlas("test_adventurer")
	_ok("walk atlas texture", walk.get("texture") != null)
	_ok("walk frames", int(walk.get("frames_per_direction", 0)) == 4)
	_ok("map provider has demo", maps.has_map("demo_field"))
	var desc := maps.get_map_descriptor("demo_field")
	_ok("map scene path set", str(desc.get("scene_path", "")).begins_with("res://"))


func _test_scene_loading() -> void:
	var main := load("res://scenes/main.tscn")
	_ok("main scene loads", main is PackedScene)
	var map := load("res://scenes/world/demo_map.tscn")
	_ok("demo map scene loads", map is PackedScene)
	var player := load("res://scenes/character/player.tscn")
	_ok("player scene loads", player is PackedScene)
	var hud := load("res://scenes/ui/mobile_hud.tscn")
	_ok("hud scene loads", hud is PackedScene)
	if map is PackedScene:
		var inst := (map as PackedScene).instantiate()
		_ok("demo map instantiates", inst is DemoMap)
		inst.free()
	if player is PackedScene:
		var p := (player as PackedScene).instantiate()
		_ok("player instantiates", p is PlayerController)
		p.free()


func _test_navigation_and_movement() -> void:
	var world := Node3D.new()
	world.name = "TestRoot"
	root.add_child(world)

	var map := DemoMap.new()
	map.name = "DemoMap"
	world.add_child(map)
	await process_frame
	await process_frame

	_ok("nav region present", map.get_navigation_region() != null)
	var nav_mesh: NavigationMesh = map.get_navigation_region().navigation_mesh
	_ok("nav mesh has vertices", nav_mesh != null and nav_mesh.get_vertices().size() >= 4)
	_ok("nav mesh has polygons", nav_mesh != null and nav_mesh.get_polygon_count() >= 1)

	var player := PlayerController.new()
	player.name = "Player"
	player.position = map.get_spawn_position()
	world.add_child(player)
	await process_frame

	var agent := player.get_navigation_agent()
	_ok("player has nav agent", agent != null)

	player.set_steer_input(Vector2(0, 1))
	for i in range(10):
		await physics_frame
	_ok(
		"steer produces velocity",
		absf(player.velocity.z) > 0.01 or player.global_position.distance_to(map.get_spawn_position()) > 0.01
	)

	player.set_steer_input(Vector2.ZERO)
	var dest := Vector3(4, 0.1, 4)
	player.move_to_world_position(dest)
	var start := player.global_position
	for i in range(45):
		await physics_frame
	var moved := player.global_position.distance_to(start) > 0.2
	_ok("pathfollowing moves player", moved, "dist=%s" % player.global_position.distance_to(start))

	var cam := ROCamera.new()
	world.add_child(cam)
	await process_frame
	cam.set_distance(16.0)
	cam.adjust_zoom(0.5)
	_ok("zoom in clamps to min", cam.get_distance() <= cam.min_distance + 0.05)
	cam.set_distance(16.0)
	cam.adjust_zoom(3.0)
	_ok("zoom out clamps to max", cam.get_distance() <= cam.max_distance + 0.05)

	world.queue_free()
	await process_frame
