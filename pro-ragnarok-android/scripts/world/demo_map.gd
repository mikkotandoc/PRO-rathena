class_name DemoMap
extends Node3D
## Offline demo field: 3D terrain mesh + NavigationRegion3D for pathfinding.

@export var map_size: Vector2 = Vector2(48, 48)
@export var obstacle_count: int = 8

var _nav_region: NavigationRegion3D


func _ready() -> void:
	_build_terrain()
	_build_obstacles()
	_build_navigation()
	_build_spawn_marker()


func get_spawn_position() -> Vector3:
	return Vector3(0, 0.1, 0)


func get_navigation_region() -> NavigationRegion3D:
	return _nav_region


func _build_terrain() -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Terrain"
	var plane := PlaneMesh.new()
	plane.size = map_size
	plane.subdivide_width = 24
	plane.subdivide_depth = 24
	mesh_instance.mesh = plane

	var mat := StandardMaterial3D.new()
	var tex := load("res://assets/placeholders/terrain/grass.png") as Texture2D
	if tex:
		mat.albedo_texture = tex
		mat.uv1_scale = Vector3(12, 12, 12)
	else:
		mat.albedo_color = Color(0.35, 0.55, 0.28)
	mat.roughness = 0.9
	mesh_instance.material_override = mat
	add_child(mesh_instance)

	var body := StaticBody3D.new()
	body.name = "TerrainBody"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(map_size.x, 0.2, map_size.y)
	col.shape = shape
	col.position = Vector3(0, -0.1, 0)
	body.add_child(col)
	add_child(body)

	# Soft hills via displaced CSG spheres under a translucent overlay feel — use MeshInstance boxes as mounds.
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(5):
		var mound := MeshInstance3D.new()
		mound.name = "Mound%d" % i
		var sphere := SphereMesh.new()
		sphere.radius = rng.randf_range(1.5, 3.0)
		sphere.height = sphere.radius * 0.7
		mound.mesh = sphere
		var mm := StandardMaterial3D.new()
		mm.albedo_color = Color(0.4, 0.58, 0.3)
		mound.material_override = mm
		mound.position = Vector3(
			rng.randf_range(-map_size.x * 0.35, map_size.x * 0.35),
			-sphere.height * 0.25,
			rng.randf_range(-map_size.y * 0.35, map_size.y * 0.35)
		)
		add_child(mound)


func _build_obstacles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(obstacle_count):
		var rock := StaticBody3D.new()
		rock.name = "Rock%d" % i
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		var s := rng.randf_range(0.8, 1.8)
		box.size = Vector3(s, s * rng.randf_range(0.6, 1.2), s)
		mi.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.45, 0.42, 0.4)
		mi.material_override = mat
		rock.add_child(mi)
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size
		col.shape = shape
		rock.add_child(col)
		var pos := Vector3(
			rng.randf_range(-map_size.x * 0.4, map_size.x * 0.4),
			box.size.y * 0.5,
			rng.randf_range(-map_size.y * 0.4, map_size.y * 0.4)
		)
		# Keep spawn clear.
		if Vector2(pos.x, pos.z).length() < 4.0:
			pos.x += 6.0
		rock.position = pos
		add_child(rock)


func _build_navigation() -> void:
	_nav_region = NavigationRegion3D.new()
	_nav_region.name = "NavigationRegion3D"
	var nav_mesh := NavigationMesh.new()
	nav_mesh.cell_size = 0.25
	nav_mesh.cell_height = 0.25
	nav_mesh.agent_height = 1.6
	nav_mesh.agent_radius = 0.4
	nav_mesh.agent_max_climb = 0.6
	# Explicit walkable plane polygon — reliable without editor bake.
	var half_x := map_size.x * 0.5 - 0.5
	var half_z := map_size.y * 0.5 - 0.5
	var verts := PackedVector3Array([
		Vector3(-half_x, 0.05, -half_z),
		Vector3(half_x, 0.05, -half_z),
		Vector3(half_x, 0.05, half_z),
		Vector3(-half_x, 0.05, half_z),
	])
	nav_mesh.vertices = verts
	nav_mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	_nav_region.navigation_mesh = nav_mesh
	add_child(_nav_region)


func _build_spawn_marker() -> void:
	var marker := MeshInstance3D.new()
	marker.name = "SpawnMarker"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.7
	torus.outer_radius = 0.9
	marker.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.85, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.5, 0.1)
	marker.material_override = mat
	marker.position = Vector3(0, 0.05, 0)
	add_child(marker)
