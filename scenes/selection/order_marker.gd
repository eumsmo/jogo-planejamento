class_name OrderMarker
extends Node3D

@export var line_tickness: float = 0.1
@export var radial_segments: int = 8

@export_group("References")
@export var label: Label3D
@export var paths_holder: Node3D
@export var sphere_mesh: MeshInstance3D


var order: int = 1
var id: Vector2i

func set_order(num: int) -> void:
	label.text = str(num)
	order = num

func remove_failed_jumps(path_arr: Array[Vector2i]) -> void:
	if len(path_arr) < 3:
		return
	
	for i in range(len(path_arr)-2, 0, -1):
		var current = path_arr[i]
		var prev = path_arr[i+1]
		var next = path_arr[i-1]
		
		if (current.x == prev.x and prev.x == next.x) or (current.y == prev.y and prev.y == next.y):
			path_arr.remove_at(i)
		

func generate_paths_to(other: Vector2i) -> void:
	var path = Game.instance.world.a_star.get_id_path(id, other)
	remove_failed_jumps(path)
	print("> ", path)
	
	var base = path[0]
	
	for i in range(0, len(path)-1):
		var from = path[i] - base
		var to = path[i+1] - base
		create_path(from, to, 1)

func create_path(from: Vector2i, to: Vector2i, is_tip: bool = false) -> Node3D:
	var mesh_instance = MeshInstance3D.new()
	paths_holder.add_child(mesh_instance)
	
	var mesh = CylinderMesh.new()
	mesh.top_radius = line_tickness
	mesh.bottom_radius = line_tickness
	mesh.radial_segments = radial_segments
	mesh.rings = 1
	mesh.cap_top = false
	mesh.cap_bottom = false
	mesh.material = sphere_mesh.mesh.surface_get_material(0)
	#mesh.flip_faces = true
	mesh.height = from.distance_to(to)
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = false
	mesh_instance.position = Vector3(from.x, 0, from.y)
	print(mesh.height)
	
	if from.y == to.y:
		var s = sign(to.x - from.x)
		mesh_instance.rotation_degrees.z = 90 * s
		mesh_instance.position.x += mesh.height/2 * s
	else:
		var s = sign(to.y - from.y)
		mesh_instance.rotation_degrees.x = 90 * s
		mesh_instance.position.z += mesh.height/2 * s
		
	
	var connection_mesh = MeshInstance3D.new()
	var connection_mesh_mesh = SphereMesh.new()
	connection_mesh_mesh.radius = mesh.top_radius
	connection_mesh_mesh.height = connection_mesh_mesh.radius * 2
	connection_mesh_mesh.radial_segments = radial_segments
	connection_mesh_mesh.rings = radial_segments/2
	connection_mesh_mesh.material = sphere_mesh.mesh.surface_get_material(0)
	
	connection_mesh.mesh = connection_mesh_mesh
	paths_holder.add_child(connection_mesh)
	connection_mesh.cast_shadow = false
	connection_mesh.position = Vector3(to.x, 0, to.y)
	
	
	
	return mesh_instance
